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
      redirect_to @asset, notice: 'Asset was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @asset
    if @asset.update(asset_params)
      redirect_to @asset, notice: 'Asset was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @asset
    @asset.destroy
    redirect_to assets_url, notice: 'Asset was successfully deleted.'
  end

  def import
    if params[:file].present?
      begin
        Asset.import(params[:file])
        redirect_to assets_path, notice: 'Assets were successfully imported.'
      rescue StandardError => e
        redirect_to assets_path, alert: "Import failed: #{e.message}"
      end
    else
      redirect_to assets_path, alert: 'Please select a file to import.'
    end
  end

  def export
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
end 