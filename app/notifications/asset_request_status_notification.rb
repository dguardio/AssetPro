class AssetRequestStatusNotification < ApplicationNotification
  required_param :asset_request

  def notification_message
    "Your asset request for #{params[:asset_request].asset.name} has been #{params[:asset_request].status}"
  end

  def custom_stream
    "notifications_#{recipient.id}"
  end
end 