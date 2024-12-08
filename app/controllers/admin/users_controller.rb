class Admin::UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy, :status_history]

  def index
    @q = policy_scope(User).ransack(params[:q])
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
    authorize @user
  end

  def update
    authorize @user

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
    authorize @user
    @user.destroy
    redirect_to admin_users_path, notice: 'User was successfully deleted.'
  end

  def status_history
    authorize @user
    @status_logs = @user.status_logs.includes(:changed_by).order(created_at: :desc)
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
end 