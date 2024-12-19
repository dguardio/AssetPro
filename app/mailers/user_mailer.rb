class UserMailer < ApplicationMailer
  def welcome
    @user = params[:user]
    mail(
      to: @user.email,
      subject: "Welcome to AssetPro - Simple, Safe Asset Management"
    )
  end

  def password_changed
    @user = params[:user]
    mail(
      to: @user.email,
      subject: "Your Password Has Been Changed"
    )
  end

  def account_status_changed
    @user = params[:user]
    mail(
      to: @user.email,
      subject: "Your Account Status Has Changed"
    )
  end

  def role_changed
    @user = params[:user]
    mail(
      to: @user.email,
      subject: "Your Role Has Been Updated"
    )
  end
end 