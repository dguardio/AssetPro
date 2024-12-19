class SystemNotifier < ApplicationNotifier
  deliver_by :email, mailer: 'SystemMailer'
  deliver_by :database

  def backup_completed
    deliver(User.with_role(:admin))
  end

  def backup_failed
    deliver(User.with_role(:admin))
  end

  def security_alert
    deliver(User.with_role(:admin))
    deliver(User.with_role(:security))
  end
end
  