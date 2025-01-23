class AssetRequestStatusNotification < ApplicationNotification
  required_param :asset_request

  deliver_by :database

  def notification_message
    {
      title: "Asset Request Status Update",
      body: "Your request for #{asset_request.asset.name} has been #{asset_request.status}",
      link: Rails.application.routes.url_helpers.asset_request_path(asset_request)
    }
  end

  def custom_stream
    "notifications_#{recipient.id}"
  end
end 