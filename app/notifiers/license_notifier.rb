class LicenseNotifier < ApplicationNotifier
  deliver_by :email, mailer: 'LicenseMailer'
  deliver_by :database

  def license_expiring
    # Notify 30 days before expiration
    deliver(params[:license].assigned_to)
  end

  def license_expired
    deliver(params[:license].assigned_to)
  end

  def seats_threshold_reached
    # When 80% of seats are used
    deliver(User.with_role(:admin))
  end
end 