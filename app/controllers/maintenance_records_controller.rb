class MaintenanceRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_asset
  before_action :set_maintenance_record, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    @q = policy_scope(@asset.maintenance_records).ransack(params[:q])
    @maintenance_records = @q.result
                            .includes(:performed_by_user)
                            .order(params[:sort] || 'maintenance_date DESC')
                            .page(params[:page]).per(10)
  end

  def show
    authorize @maintenance_record
  end

  def new
    @maintenance_record = @asset.maintenance_records.build
    authorize @maintenance_record
  end

  def edit
    authorize @maintenance_record
  end

  def create
    @maintenance_record = @asset.maintenance_records.build(maintenance_record_params)
    @maintenance_record.performed_by_user = current_user
    authorize @maintenance_record

    if @maintenance_record.save
      redirect_to asset_maintenance_record_path(@asset, @maintenance_record), 
                  notice: 'Maintenance record was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @maintenance_record
    if @maintenance_record.update(maintenance_record_params)
      redirect_to asset_maintenance_record_path(@asset, @maintenance_record), 
                  notice: 'Maintenance record was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @maintenance_record
    @maintenance_record.destroy
    redirect_to asset_maintenance_records_path(@asset), 
                notice: 'Maintenance record was successfully deleted.'
  end

  private

  def set_asset
    @asset = Asset.find(params[:asset_id])
  end

  def set_maintenance_record
    @maintenance_record = @asset.maintenance_records.find(params[:id])
  end

  def maintenance_record_params
    params.require(:maintenance_record).permit(
      :maintenance_date, 
      :description, 
      :cost, 
      :maintenance_type,
      :status
    )
  end
end 