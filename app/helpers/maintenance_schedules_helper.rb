module MaintenanceSchedulesHelper
  def format_next_due_date(schedule)
    return 'Not Set' unless schedule.next_due_at

    date_str = schedule.next_due_at.strftime("%Y-%m-%d")
    if schedule.status == 'completed'
      "<span class='text-success'>#{date_str}</span>".html_safe
    elsif schedule.overdue?
      "<span class='text-danger'>#{date_str} (Overdue)</span>".html_safe
    elsif schedule.due_soon?
      "<span class='text-warning'>#{date_str} (Due Soon)</span>".html_safe
    else
      date_str
    end
  end

  def format_frequency(frequency)
    return 'Not Set' unless frequency
    return 'Custom' if frequency == 'custom'
    frequency.titleize
  end
end 