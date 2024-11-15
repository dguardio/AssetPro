class MaintenanceDueNotification < ApplicationNotification
  param :maintenance_schedule

  def url
    maintenance_schedule_path(params[:maintenance_schedule])
  end

  def message
    schedule = params[:maintenance_schedule]
    "Maintenance is due for #{schedule.asset.name} on #{schedule.scheduled_date.strftime('%B %d, %Y')}"
  end
end 