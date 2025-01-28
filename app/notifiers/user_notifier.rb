class UserNotifier < ApplicationNotifier
  deliver_by :email do |config|
    config.mailer = "UserMailer"
    config.method = :notification_email
  end
  # deliver_by :database

  required_param :user
  required_param :notification_type

  def message
    case params[:notification_type]
    when :welcome
      "Welcome to AssetPro, #{params[:user].full_name}!"
    when :password_changed
      "Your password has been changed"
    when :account_status_changed
      "Your account status has been updated"
    when :role_changed
      "Your role has been updated to #{params[:user].role}"
    else
      "You have a new notification"
    end
  end

  def url
    Rails.application.routes.url_helpers.user_path(params[:user])
  end

  def self.welcome(user)
    with(user: user, notification_type: :welcome).deliver_later(user)
  end

  def self.password_changed(user)
    with(user: user, notification_type: :password_changed).deliver_later(user)
  end

  def self.account_status_changed(user)
    with(user: user, notification_type: :account_status_changed).deliver_later(user)
  end

  def self.role_changed(user)
    with(user: user, notification_type: :role_changed).deliver_later(user)
  end
end 