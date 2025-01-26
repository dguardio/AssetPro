class RfidNotifier < ApplicationNotifier
  deliver_by :email, mailer: 'RfidMailer'
  # deliver_by :database

  required_param :notification_type
  param :asset, optional: true
  param :scan, optional: true
  param :location, optional: true
  param :reader, optional: true

  def message
    case params[:notification_type]
    when :unauthorized_scan_attempt
      "Unauthorized RFID scan attempt at #{params[:location]}"
    when :reader_offline
      "RFID Reader #{params[:reader].name} is offline"
    when :tag_deactivated
      "RFID tag deactivated for asset: #{params[:asset].name}"
    end
  end

  def url
    case params[:notification_type]
    when :unauthorized_scan_attempt
      Rails.application.routes.url_helpers.rfid_scans_path
    when :reader_offline
      Rails.application.routes.url_helpers.rfid_readers_path
    when :tag_deactivated
      Rails.application.routes.url_helpers.asset_path(params[:asset])
    end
  end

  def self.unauthorized_scan_attempt(scan, location)
    with(
      notification_type: :unauthorized_scan_attempt,
      scan: scan,
      location: location
    ).deliver_later(User.with_role(:security) + User.with_role(:admin))
  end

  def self.reader_offline(reader)
    with(
      notification_type: :reader_offline,
      reader: reader
    ).deliver_later(User.with_role(:admin))
  end

  def self.tag_deactivated(asset)
    with(
      notification_type: :tag_deactivated,
      asset: asset
    ).deliver_later([asset.assigned_to] + User.with_role(:security))
  end
end