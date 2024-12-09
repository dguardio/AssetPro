module Admin::AssetTrackingEventsHelper
  def timeline_event_color(event)
    case event.event_type
    when 'movement'
      'info'
    when 'check_out'
      'warning'
    when 'check_in'
      'success'
    when 'assigned'
      'primary'
    when 'unassigned'
      'secondary'
    when 'inventory'
      'dark'
    else
      'secondary'
    end
  end

  def timeline_event_icon(event)
    case event.event_type
    when 'movement'
      'swap_horiz'
    when 'check_out'
      'logout'
    when 'check_in'
      'login'
    when 'assigned'
      'person_add'
    when 'unassigned'
      'person_remove'
    when 'inventory'
      'inventory'
    else
      'radio_button_checked'
    end
  end

  def timeline_event_description(event)
    case event.event_type
    when 'movement'
      "Detected at #{event.location.name}"
    when 'check_out'
      "Checked out from #{event.location.name}"
    when 'check_in'
      "Checked in to #{event.location.name}"
    when 'assigned'
      "Assigned to #{event.asset_assignment.user.full_name} at #{event.location.name}"
    when 'unassigned'
      "Unassigned from #{event.asset_assignment.user.full_name} at #{event.location.name}"
    when 'inventory'
      "Inventoried at #{event.location.name}"
    else
      "Event at #{event.location.name}"
    end
  end
end
