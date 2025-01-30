class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = policy_scope(Noticed::Notification).newest_first.page(params[:page])
  end

  def mark_as_read
    @notification = policy_scope(Noticed::Notification).find(params[:id])
    authorize @notification, :mark_as_read?
    @notification.mark_as_read!
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.json { render json: { success: true } }
    end
  end

  def mark_all_as_read
    @notifications = policy_scope(Noticed::Notification).unread
    authorize Noticed::Notification, :mark_all_as_read?
    @notifications.update_all(read_at: Time.current)
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: notifications_path) }
      format.json { render json: { success: true } }
    end
  end
end 