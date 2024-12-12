module Profile
  class PasswordsController < ApplicationController
    layout 'application'
    before_action :authenticate_user!
    
    def edit
      @user = current_user
      authorize [:profile, @user], policy_class: Profile::PasswordPolicy
      set_minimum_password_length
    end

    def update
      @user = current_user
      authorize [:profile, @user], policy_class: Profile::PasswordPolicy
      if @user.update_with_password(password_params)
        bypass_sign_in(@user)
        redirect_to profile_edit_password_path, notice: "Password updated successfully."
      else
        set_minimum_password_length
        render :edit
      end
    end

    private

    def password_params
      params.require(:user).permit(:current_password, :password, :password_confirmation)
    end

    def set_minimum_password_length
      @minimum_password_length = User.password_length.min
    end
  end
end 