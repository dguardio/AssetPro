class SystemMailer < ApplicationMailer
  def notification_email
    @notification = params[:notification]
    @recipient = params[:recipient]
    
    subject = case @notification.params[:notification_type]
    when :backup_completed
      "System Backup Completed Successfully"
    when :backup_failed
      "System Backup Failed"
    when :security_alert
      "Security Alert"
    end
    
    mail(
      to: @recipient.email,
      subject: subject
    )
  end
end 