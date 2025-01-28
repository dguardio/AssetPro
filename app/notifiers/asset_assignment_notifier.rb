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
  required_param :notification_type

  def message
    case params[:notification_type]
    when :created
      "You have been assigned #{params[:asset_assignment].asset.name} by #{params[:asset_assignment].assigned_by.full_name}"
    when :checked_out
      "#{params[:asset_assignment].asset.name} has been checked out"
    when :checked_in
      "#{params[:asset_assignment].asset.name} has been checked in"
    end
  end

  def url
    Rails.application.routes.url_helpers.asset_path(params[:asset_assignment].asset)
  end

  def self.assignment_created(asset_assignment)
    with(
      asset_assignment: asset_assignment,
      notification_type: :created
    ).deliver_later(asset_assignment.user)
  end

  def self.checked_out(asset_assignment)
    with(
      asset_assignment: asset_assignment,
      notification_type: :checked_out
    ).deliver_later(asset_assignment.user)
  end

  def self.checked_in(asset_assignment)
    with(
      asset_assignment: asset_assignment,
      notification_type: :checked_in
    ).deliver_later(asset_assignment.user)
  end
end
