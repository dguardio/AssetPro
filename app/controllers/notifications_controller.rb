class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.newest_first.page(params[:page])
  end

  def mark_as_read
    notifications = current_user.notifications.unread
    notifications.update_all(read_at: Time.current)
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path, notice: 'All notifications marked as read') }
      format.json { render json: { success: true } }
    end
  end

  def destroy
    @notification = current_user.notifications.find(params[:id])
    @notification.destroy
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path, notice: 'Notification removed') }
      format.json { render json: { success: true } }
    end
  end
end 