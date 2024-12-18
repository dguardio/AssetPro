class MaintenanceCompletedNotification < ApplicationNotification
  param :maintenance_schedule
  param :completed_by

  def message
    "Maintenance for #{params[:maintenance_schedule].asset.name} has been completed by #{params[:completed_by].name}"
  end

  def url
    maintenance_schedule_path(params[:maintenance_schedule])
  end
end 