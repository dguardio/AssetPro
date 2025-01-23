module AssetRequestsHelper
  def request_status_color(status)
    case status
    when 'pending'
      'warning'
    when 'approved'
      'success'
    when 'rejected'
      'danger'
    when 'cancelled'
      'secondary'
    else
      'info'
    end
  end
end 