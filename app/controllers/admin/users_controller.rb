class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    authorize :admin_user, :index?
    @users = policy_scope([:admin, User]).order(created_at: :desc).page(params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params_without_role)
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
    authorize [:admin, @user]
  end

  def update
    authorize [:admin, @user]

    User.transaction do
      if @user.update(user_params_without_role)
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
    @user.destroy
    redirect_to admin_users_path, notice: 'User was successfully deleted.'
  end

  def status_history
    @user = User.find(params[:id])
    @status_logs = @user.account_status_logs.includes(:changed_by).order(created_at: :desc)
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

  def require_admin
    unless current_user.admin?
      redirect_to root_path, alert: 'You are not authorized to access this area.'
    end
  end
end 