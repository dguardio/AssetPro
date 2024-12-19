class MaintenanceSchedulesController < ApplicationController
  before_action :set_maintenance_schedule, only: [:show, :edit, :update, :destroy, :complete]

  def index
    @q = policy_scope(MaintenanceSchedule).ransack(params[:q])
    @maintenance_schedules = @q.result.includes(:asset, :assigned_to)
    .order(params[:sort] || 'created_at DESC')
    .page(params[:page]).per(10)
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
      notify_maintenance_changes
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

  def complete
    authorize @maintenance_schedule
    
    if @maintenance_schedule.update(completed_date: Time.current, status: 'completed')
      redirect_to maintenance_schedules_path, notice: 'Maintenance schedule marked as completed.'
    else
      redirect_to maintenance_schedules_path, alert: 'Unable to complete maintenance schedule.'
    end
  end

  private

  def set_maintenance_schedule
    @maintenance_schedule = MaintenanceSchedule.find(params[:id])
  end

  def maintenance_schedule_params
    params.require(:maintenance_schedule).permit(:title, :status, :description, :frequency, :last_performed_at, :next_due_at, :asset_id, :assigned_to_id, :notes, :completed_date, :last_performed_at)
  end

  def notify_maintenance_changes
    if @maintenance_schedule.status_changed? && @maintenance_schedule.completed?
      @maintenance_schedule.notify_completion
    end

    if @maintenance_schedule.due_date <= 7.days.from_now
      AssetNotifier.with(
        asset: @maintenance_schedule.asset
      ).maintenance_due
    end
  end
end 