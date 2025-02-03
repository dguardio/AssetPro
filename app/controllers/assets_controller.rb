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
    previous_assignee = @asset.current_assignment.user
    
    authorize @asset
    if @asset.update(asset_params)
      notify_asset_changes(previous_assignee)
      redirect_to inventory_asset_path(@asset), notice: 'Asset was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @asset = Asset.find(params[:id])
    authorize @asset
    
    if @asset.destroy
      respond_to do |format|
        format.html { redirect_to inventory_assets_url, notice: 'Asset was successfully archived.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to inventory_assets_url, alert: 'Failed to archive asset.' }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
    end
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

  def restore
    @asset = Asset.with_deleted.find(params[:id])
    authorize @asset
    
    if @asset.recover
      respond_to do |format|
        format.html { redirect_to assets_url, notice: 'Asset was successfully restored.' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to assets_url, alert: 'Failed to restore asset.' }
        format.json { render json: @asset.errors, status: :unprocessable_entity }
      end
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
      if @asset.current_assignment.user
        AssetAssignmentNotification.with(
          asset_assignment: @asset.current_assignment
        ).deliver_later(@asset.current_assignment.user)
      end

      if previous_assignee
        AssetNotifier.assignment_removed(@asset, previous_assignee)
      end
    end

    if @asset.quantity && @asset.quantity <= @asset.minimum_quantity
      LowStockNotifier.minimum_reached(@asset)
    end
  end
end 