module AssetsHelper
  def status_color(status)
    case status.to_sym
    when :available
      'success'
    when :in_use
      'info'
    when :maintenance
      'warning'
    when :retired
      'secondary'
    else
      'primary'
    end
  end
end 