class MaintenanceRecordsController < ApplicationController
  before_action :set_maintenance_record, only: [:show, :edit, :update, :destroy, :restore]

  def index
    @asset = Asset.find(params[:asset_id])
    @q = policy_scope(@asset.maintenance_records).ransack(params[:q])
    @maintenance_records = @q.result
    @maintenance_records = @maintenance_records.only_deleted if params[:show_deleted]
    @maintenance_records = @maintenance_records.includes(:performed_by)
      .order(maintenance_date: :desc)
      .page(params[:page])
      .per(10)
  end

  def show
    authorize @maintenance_record
  end

  def new
    @maintenance_record = MaintenanceRecord.new
    authorize @maintenance_record
  end

  def edit
    authorize @maintenance_record
  end

  def create
    @maintenance_record = MaintenanceRecord.new(maintenance_record_params)
    @maintenance_record.performed_by = current_user
    authorize @maintenance_record

    if @maintenance_record.save
      redirect_to @maintenance_record, notice: 'Maintenance record was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @maintenance_record
    if @maintenance_record.update(maintenance_record_params)
      redirect_to @maintenance_record, notice: 'Maintenance record was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @maintenance_record
    if @maintenance_record.destroy
      redirect_to asset_maintenance_records_url(@maintenance_record.asset), notice: 'Maintenance record was successfully archived.'
    else
      redirect_to asset_maintenance_records_url(@maintenance_record.asset), alert: 'Failed to archive maintenance record.'
    end
  end

  def restore
    @maintenance_record = MaintenanceRecord.only_deleted.find(params[:id])
    authorize @maintenance_record
    
    if @maintenance_record.restore
      redirect_to asset_maintenance_records_url(@maintenance_record.asset), notice: 'Maintenance record was successfully restored.'
    else
      redirect_to asset_maintenance_records_url(@maintenance_record.asset), alert: 'Failed to restore maintenance record.'
    end
  end

  private

  def set_maintenance_record
    #Set maintenance record if soft deleted or not
    @maintenance_record = params[:id].present? ? MaintenanceRecord.with_deleted.find(params[:id]) : MaintenanceRecord.new
  end

  def maintenance_record_params
    params.require(:maintenance_record).permit(:maintenance_date, :description, :cost, :asset_id, :maintenance_schedule_id)
  end
end 