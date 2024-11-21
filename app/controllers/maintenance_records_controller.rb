class MaintenanceRecordsController < ApplicationController
  before_action :set_maintenance_record, only: [:show, :edit, :update, :destroy]

  def index
    @q = policy_scope(MaintenanceRecord).ransack(params[:q])
    @maintenance_records = @q.result.includes(:asset, :performed_by).page(params[:page])
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
    @maintenance_record.destroy
    redirect_to maintenance_records_url, notice: 'Maintenance record was successfully deleted.'
  end

  private

  def set_maintenance_record
    @maintenance_record = MaintenanceRecord.find(params[:id])
  end

  def maintenance_record_params
    params.require(:maintenance_record).permit(:maintenance_date, :description, :cost, :asset_id, :maintenance_schedule_id)
  end
end 