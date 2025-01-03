module AuditLogsHelper
  def format_change_value(value)
    case value
    when nil
      'nil'
    when ''
      '(empty string)'
    when true
      'true'
    when false
      'false'
    else
      value.to_s
    end
  end

  def audit_action_badge_color(action)
    case action
    when 'create'
      'success'
    when 'update'
      'info'
    when 'destroy'
      'danger'
    else
      'secondary'
    end
  end
end 