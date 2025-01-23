class UserNotifier < ApplicationNotifier
  deliver_by :email, mailer: 'UserMailer'
  # deliver_by :database

  def welcome
    deliver(params[:user])
  end

  def password_changed
    deliver(params[:user])
  end

  def account_status_changed
    deliver(params[:user])
  end

  def role_changed
    deliver(params[:user])
  end
end 