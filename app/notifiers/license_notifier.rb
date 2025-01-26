class LicenseNotifier < ApplicationNotifier
  deliver_by :email, mailer: 'LicenseMailer'
  # deliver_by :database

  required_param :license
  required_param :notification_type

  def message
    case params[:notification_type]
    when :license_expiring
      "License for #{params[:license].name} is expiring in 30 days"
    when :license_expired
      "License for #{params[:license].name} has expired"
    when :seats_threshold_reached
      "License #{params[:license].name} has reached 80% seat capacity"
    end
  end

  def url
    Rails.application.routes.url_helpers.license_path(params[:license])
  end

  def self.license_expiring(license)
    with(
      license: license,
      notification_type: :license_expiring
    ).deliver_later(license.assigned_to)
  end

  def self.license_expired(license)
    with(
      license: license,
      notification_type: :license_expired
    ).deliver_later(license.assigned_to)
  end

  def self.seats_threshold_reached(license)
    with(
      license: license,
      notification_type: :seats_threshold_reached
    ).deliver_later(User.with_role(:admin))
  end
end 