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
end 