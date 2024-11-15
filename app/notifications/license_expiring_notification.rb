class LicenseExpiringNotification < ApplicationNotification
  param :license

  def url
    license_path(params[:license])
  end

  def message
    license = params[:license]
    "License #{license.name} will expire on #{license.expiration_date.strftime('%B %d, %Y')}"
  end
end 