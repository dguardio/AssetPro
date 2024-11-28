class Users::SessionsController < Devise::SessionsController
  # Skip Pundit authorization for Devise actions
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped
  
  def create
    self.resource = warden.authenticate!(auth_options)
    if resource.active?
      super
    else
      sign_out resource
      flash[:alert] = I18n.t('devise.failure.deactivated_account')
      redirect_to new_user_session_path
    end
  end
end 