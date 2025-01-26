class SystemNotifier < ApplicationNotifier
  deliver_by :email, mailer: 'SystemMailer'
  # deliver_by :database

  param :notification_type
  param :details, optional: true

  def message
    case params[:notification_type]
    when :backup_completed
      "System backup completed successfully"
    when :backup_failed
      "System backup failed"
    when :security_alert
      "Security alert: #{params[:details]}"
    end
  end

  def url
    Rails.application.routes.url_helpers.root_path
  end

  def self.backup_completed
    with(notification_type: :backup_completed)
      .deliver_later(User.with_role(:admin))
  end

  def self.backup_failed
    with(notification_type: :backup_failed)
      .deliver_later(User.with_role(:admin))
  end

  def self.security_alert(details = nil)
    with(notification_type: :security_alert, details: details)
      .deliver_later(User.with_role(:admin) + User.with_role(:security))
  end
end
  