class AssetRequestNotification < ApplicationNotification
  required_param :asset_request

  def notification_message
    "New asset request from #{params[:asset_request].user.email}"
  end

  def custom_stream
    "notifications_#{recipient.id}"
  end
end 