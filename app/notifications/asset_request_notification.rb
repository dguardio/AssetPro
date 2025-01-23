class AssetRequestNotification < ApplicationNotification
  required_param :asset_request

  deliver_by :database
  deliver_by :action_cable, 
            channel: "NotificationChannel", 
            stream: :custom_stream, 
            message: :notification_message

  def notification_message
    {
      title: "New Asset Request",
      body: "#{asset_request.user.name} requested #{asset_request.asset.name}",
      link: Rails.application.routes.url_helpers.asset_request_path(asset_request)
    }
  end

  def custom_stream
    "notifications_#{recipient.id}"
  end
end 