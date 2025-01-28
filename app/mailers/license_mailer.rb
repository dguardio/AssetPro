class LicenseMailer < ApplicationMailer
  def notification_email
    @notification = params[:notification]
    @recipient = params[:recipient]
    @license = @notification.params[:license]
    
    subject = case @notification.params[:notification_type]
    when :license_expiring
      "License Expiring Soon: #{@license.name}"
    when :license_expired
      "License Expired: #{@license.name}"
    when :seats_threshold_reached
      "License Capacity Alert: #{@license.name}"
    end
    
    mail(
      to: @recipient.email,
      subject: subject
    )
  end
end 