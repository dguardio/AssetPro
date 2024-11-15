module DashboardsHelper
  def search_params
    params[:q]&.permit(
      :category_id_eq,
      :location_id_eq,
      :status_eq,
      :rfid_enabled_eq,
      :s
    )&.to_h || {}
  end
  
  def maintenance_status_color(status)
    case status
    when 'scheduled' then 'info'
    when 'in_progress' then 'warning'
    when 'completed' then 'success'
    when 'overdue' then 'danger'
    end
  end
  
  def license_status_color(license)
    if license.expiration_date < Date.current
      'danger'
    elsif license.expiration_date < 30.days.from_now
      'warning'
    else
      'success'
    end
  end
  
  def license_status(license)
    if license.expiration_date < Date.current
      'Expired'
    elsif license.expiration_date < 30.days.from_now
      'Expiring Soon'
    else
      'Active'
    end
  end  
end 