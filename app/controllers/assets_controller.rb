class AssetsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_asset, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @q = policy_scope(Asset).ransack(params[:q])
    @assets = @q.result.includes(:category, :location)
                .order(params[:sort] || 'created_at DESC')
                .page(params[:page]).per(10)
  end

  def show
    authorize @asset
  end

  def new
    @asset = Asset.new
    authorize @asset
  end

  def edit
    authorize @asset
  end

  def create
    @asset = Asset.new(asset_params)
    authorize @asset

    if @asset.save
      redirect_to inventory_asset_path(@asset), notice: 'Asset was successfully created.'
    else
      render :new
    end
  end

  def update
    previous_assignee = @asset.assigned_to
    
    authorize @asset
    if @asset.update(asset_params)
      notify_asset_changes(previous_assignee)
      redirect_to inventory_asset_path(@asset), notice: 'Asset was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @asset
    @asset.destroy
    redirect_to inventory_assets_url, notice: 'Asset was successfully deleted.'
  end

  def import
    authorize Asset, :import?
    if params[:file].present?
      begin
        Asset.import(params[:file])
        redirect_to inventory_assets_path, notice: 'Assets were successfully imported.'
      rescue StandardError => e
        redirect_to inventory_assets_path, alert: "Import failed: #{e.message}"
      end
    else
      redirect_to inventory_assets_path, alert: 'Please select a file to import.'
    end
  end

  def export
    authorize Asset, :export?
    respond_to do |format|
      format.csv { send_data Asset.to_csv, filename: "assets-#{Date.current}.csv" }
    end
  end

  private

  def set_asset
    @asset = Asset.find(params[:id])
  end

  def asset_params
    params.require(:asset).permit(:name, :description, :category_id, :location_id, :status)
  end

  def notify_asset_changes(previous_assignee)
    if @asset.saved_change_to_location_id?
      AssetNotifier.with(asset: @asset).location_changed
    end

    if @asset.saved_change_to_assigned_to_id?
      if @asset.assigned_to
        AssetAssignmentNotification.with(
          asset_assignment: @asset.current_assignment
        ).deliver_later(@asset.assigned_to)
      end

      if previous_assignee
        AssetNotifier.with(
          asset: @asset,
          previous_assignee: previous_assignee
        ).assignment_removed
      end
    end

    if @asset.quantity && @asset.quantity <= @asset.minimum_quantity
      LowStockNotification.with(asset: @asset)
        .deliver_later(User.with_role(:manager))
    end
  end
end 