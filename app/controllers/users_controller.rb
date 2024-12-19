class UsersController < ApplicationController
  def create
    if @user.save
      UserNotifier.with(user: @user).welcome
      redirect_to @user, notice: 'User created successfully.'
    else
      render :new
    end
  end

  def update
    previous_role = @user.role
    previous_status = @user.status

    if @user.update(user_params)
      notify_user_changes(previous_role, previous_status)
      redirect_to @user, notice: 'User updated successfully.'
    else
      render :edit
    end
  end

  private

  def notify_user_changes(previous_role, previous_status)
    if @user.role != previous_role
      UserNotifier.with(user: @user).role_changed
    end

    if @user.status != previous_status
      UserNotifier.with(user: @user).account_status_changed
    end

    if params[:user][:password].present?
      UserNotifier.with(user: @user).password_changed
    end
  end
end 