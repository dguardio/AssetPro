class MaintenanceSchedulesController < ApplicationController
  before_action :set_maintenance_schedule, only: [:show, :edit, :update, :destroy]

  def index
    @q = policy_scope(MaintenanceSchedule).ransack(params[:q])
    @maintenance_schedules = @q.result.includes(:asset, :assigned_to).page(params[:page])
  end

  def show
    authorize @maintenance_schedule
  end

  def new
    @maintenance_schedule = MaintenanceSchedule.new
    authorize @maintenance_schedule
  end

  def edit
    authorize @maintenance_schedule
  end

  def create
    @maintenance_schedule = MaintenanceSchedule.new(maintenance_schedule_params)
    authorize @maintenance_schedule

    if @maintenance_schedule.save
      redirect_to @maintenance_schedule, notice: 'Maintenance schedule was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @maintenance_schedule
    if @maintenance_schedule.update(maintenance_schedule_params)
      redirect_to @maintenance_schedule, notice: 'Maintenance schedule was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @maintenance_schedule
    @maintenance_schedule.destroy
    redirect_to maintenance_schedules_url, notice: 'Maintenance schedule was successfully deleted.'
  end

  private

  def set_maintenance_schedule
    @maintenance_schedule = MaintenanceSchedule.find(params[:id])
  end

  def maintenance_schedule_params
    params.require(:maintenance_schedule).permit(:title, :description, :frequency, :last_performed_at, :next_due_at, :asset_id, :assigned_to_id)
  end
end 