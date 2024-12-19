class RfidNotifier < ApplicationNotifier
  deliver_by :email, mailer: 'RfidMailer'
  deliver_by :database

  def unauthorized_scan_attempt
    deliver(User.with_role(:security))
    deliver(User.with_role(:admin))
  end

  def reader_offline
    deliver(User.with_role(:admin))
  end

  def tag_deactivated
    deliver(params[:asset].assigned_to)
    deliver(User.with_role(:security))
  end
end