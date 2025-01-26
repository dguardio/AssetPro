# To deliver this notification:
#
# AssetAssignmentNotifier.with(record: @post, message: "New post").deliver(User.all)

class AssetAssignmentNotifier < ApplicationNotifier
  # deliver_by :database
  deliver_by :email do |config|
    config.mailer = "AssetAssignmentMailer"
    config.method = :notification_email
  end

  required_param :asset_assignment

  def message
    t(".message", 
      asset: params[:asset_assignment].asset.name,
      assigned_by: params[:asset_assignment].assigned_by.full_name)
  end

  def url
    Rails.application.routes.url_helpers.asset_path(params[:asset_assignment].asset)
  end

  def self.notify_assignment(assignment)
    with(asset_assignment: assignment).deliver_later(assignment.user)
  end
end
