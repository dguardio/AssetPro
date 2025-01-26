class AssetRequestNotifier < ApplicationNotifier
  deliver_by :email do |config|
    config.mailer = "AssetRequestMailer"
    config.method = :notification_email
  end

  required_param :asset_request
  required_param :notification_type

  def message
    case params[:notification_type]
    when :new_request
      "New asset request from #{params[:asset_request].user.email}"
    when :status_changed
      "Your asset request for #{params[:asset_request].asset.name} has been #{params[:asset_request].status}"
    end
  end

  def url
    Rails.application.routes.url_helpers.asset_request_path(params[:asset_request])
  end

  def self.new_request(asset_request)
    with(
      asset_request: asset_request,
      notification_type: :new_request
    ).deliver_later(User.with_role(:manager))
  end

  def self.status_changed(asset_request)
    with(
      asset_request: asset_request,
      notification_type: :status_changed
    ).deliver_later(asset_request.user)
  end
end 