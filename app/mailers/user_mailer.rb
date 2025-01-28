class UserMailer < ApplicationMailer
  def notification_email
    @notification = params[:notification]
    @recipient = params[:recipient]
    @user = @notification.params[:user]
    
    subject = case @notification.params[:notification_type]
    when :welcome
      "Welcome to AssetPro - Simple, Safe Asset Management"
    when :password_changed
      "Your Password Has Been Changed"
    when :account_status_changed
      "Your Account Status Has Changed"
    when :role_changed
      "Your Role Has Been Updated"
    end
    
    mail(
      to: @recipient.email,
      subject: subject
    )
  end
end 