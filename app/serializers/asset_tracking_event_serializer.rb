class AssetTrackingEventSerializer < ActiveModel::Serializer
  attributes :id,
             :event_type,
             :asset_id,
             :rfid_number,
             :scanned_at,
             :rfid_number,
             :scanned_at,
             :created_at,
             :updated_at

  belongs_to :asset
  belongs_to :location
  belongs_to :scanned_by, class_name: 'User'
  belongs_to :scanned_by_device, class_name: 'RfidReader'
  belongs_to :oauth_application
  belongs_to :asset_assignment, optional: true
end 