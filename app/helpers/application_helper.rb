module ApplicationHelper
  def sort_link_with_icon(search_object, attribute, *args)
    label = args.first || attribute.to_s.titleize
    sort_link(search_object, attribute, label) do |sorted_label|
      direction = search_object.sorts.find { |s| s.name == attribute.to_s }&.dir
      icon = case direction
             when 'asc' then '↑'
             when 'desc' then '↓'
             else '↕'
             end
      "#{sorted_label} #{icon}".html_safe
    end
  end

  def status_badge(status)
    class_map = {
      active: 'success',
      inactive: 'secondary',
      maintenance: 'warning',
      retired: 'danger'
    }
    
    content_tag(:span, status.titleize, class: "badge badge-#{class_map[status.to_sym]}")
  end

  def status_badge_class(status)
    case status&.to_sym
    when :available
      'bg-success'
    when :in_use
      'bg-primary'
    when :maintenance
      'bg-warning'
    when :retired
      'bg-danger'
    else
      'bg-secondary'
    end
  end

  def status_color(status)
    case status
    when 'available'
      'success'
    when 'in_use'
      'warning'
    when 'in_maintenance'
      'info'
    else
      'secondary'
    end
  end
end
