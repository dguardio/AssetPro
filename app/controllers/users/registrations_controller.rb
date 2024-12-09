class Users::RegistrationsController < Devise::RegistrationsController
  layout 'auth'
  include Pundit::Authorization
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # Skip the authorization for specific actions that don't need it
  skip_after_action :verify_authorized, only: [:new, :create]
  
  def edit
    authorize resource
    super
  end

  def update
    authorize resource
    super
  end

  def destroy
    authorize resource
    super
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :role])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  protected

  def after_update_path_for(resource)
    edit_user_registration_path
  end

  def after_sign_up_path_for(resource)
    edit_user_registration_path
  end
end 
