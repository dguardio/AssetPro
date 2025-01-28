class AssetStatusNotifier < ApplicationNotifier
  deliver_by :email do |config|
    config.mailer = "AssetMailer"
    config.method = :notification_email
  end
  # deliver_by :action_cable

  required_param :asset
  required_param :notification_type
  param :changed_by, optional: true

  def message
    "Asset #{params[:asset].name} status changed to #{params[:asset].status}" +
    (params[:changed_by] ? " by #{params[:changed_by].name}" : "")
  end

  def url
    Rails.application.routes.url_helpers.asset_path(params[:asset])
  end

  def self.status_changed(asset, changed_by = nil)
    recipients = User.with_role(:admin) + User.with_role(:manager)
    
    with(
      asset: asset,
      notification_type: :status_changed,
      changed_by: changed_by
    ).deliver_by(:action_cable, message: {
      title: 'Asset Status Changed',
      body: "The status of #{asset.name} has been changed to #{asset.status}.",
      asset_id: asset.id
    }).deliver_later(recipients)
  end
end 