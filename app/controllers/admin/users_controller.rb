class Admin::UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy, :status_history, :lock, :unlock]

  def index
    @q = policy_scope(User).ransack(params[:q])
    @q.sorts = 'email asc' if @q.sorts.empty?
    @users = @q.result(distinct: true).page(params[:page])
  end

  def show
    @user = User.find(params[:id])
    authorize @user
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new(user_params)
    authorize @user

    User.transaction do
      if @user.save
        # Handle role assignment
        new_role = params[:user][:role]
        @user.add_role(new_role) if new_role.present? && User.available_roles.include?(new_role)
        
        redirect_to admin_users_path, notice: 'User was successfully created.'
      else
        render :new
      end
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    User.transaction do
      if @user.update(user_params)
        # Handle role assignment
        new_role = params[:user][:role]
        if new_role.present? && User.available_roles.include?(new_role)
          @user.roles.destroy_all # Remove existing roles
          @user.add_role new_role
        end

        redirect_to admin_users_path, notice: 'User was successfully updated.'
      else
        render :edit
      end
    end
  end

  def destroy
    authorize @user
    if @user.deactivate!
      redirect_to admin_users_path, notice: 'User account was successfully deactivated.'
    else
      redirect_to admin_users_path, alert: 'Failed to deactivate user account.'
    end
  end

  def reactivate
    authorize @user
    if @user.reactivate!
      redirect_to admin_users_path, notice: 'User account was successfully reactivated.'
    else
      redirect_to admin_users_path, alert: 'Failed to reactivate user account.'
    end
  end

  def status_history
    authorize @user
    @status_logs = @user.status_logs.includes(:changed_by).order(created_at: :desc)
  end

  def lock
    authorize @user
    if @user.lock_access!(send_instructions: true)
      @user.send_lock_notification(params[:reason])  # Add this line
      log_account_status_change('locked', params[:reason])
      redirect_to admin_users_path, notice: 'User account was successfully locked.'
    else
      redirect_to admin_users_path, alert: 'Failed to lock user account.'
    end
  end
  
  def unlock
    authorize @user
    if @user.unlock_access!
      @user.send_unlock_instructions  # Add this line
      log_account_status_change('unlocked', params[:reason])
      redirect_to admin_users_path, notice: 'User account was successfully unlocked.'
    else
      redirect_to admin_users_path, alert: 'Failed to unlock user account.'
    end
  end  

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :role,
      :first_name,
      :last_name,
      :active
    )
  end

  def user_params_without_role
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :first_name,
      :last_name,
      :active
    )
  end

  def log_account_status_change(action, reason)
    @user.account_status_logs.create!(
      changed_by: current_user,
      status_from: action == 'locked' ? true : false,
      status_to: action == 'locked' ? false : true,
      reason: reason || "Account #{action} by administrator"
    )
  end
end 