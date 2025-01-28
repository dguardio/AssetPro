class AssetNotifier < ApplicationNotifier
  deliver_by :email do |config|
    config.mailer = "AssetMailer"
    config.method = :notification_email
  end
  # deliver_by :database

  required_param :asset
  param :previous_assignee, optional: true

  def message
    case params[:notification_type]
    when :maintenance_due
      "Maintenance is due for #{params[:asset].name}"
    when :location_changed
      "Location changed for #{params[:asset].name}"
    when :assignment_created
      "You have been assigned #{params[:asset].name}"
    when :assignment_removed
      "Your assignment for #{params[:asset].name} has been removed"
    end
  end

  def url
    Rails.application.routes.url_helpers.asset_path(params[:asset])
  end

  def self.maintenance_due(asset)
    with(asset: asset, notification_type: :maintenance_due)
      .deliver_later([asset.assigned_to] + User.with_role(:manager))
  end

  def self.location_changed(asset)
    with(asset: asset, notification_type: :location_changed)
      .deliver_later(asset.assigned_to)
  end

  def self.assignment_created(asset)
    with(asset: asset, notification_type: :assignment_created)
      .deliver_later(asset.assigned_to)
  end

  def self.assignment_removed(asset, previous_assignee)
    with(
      asset: asset,
      previous_assignee: previous_assignee,
      notification_type: :assignment_removed
    ).deliver_later(previous_assignee)
  end
end 