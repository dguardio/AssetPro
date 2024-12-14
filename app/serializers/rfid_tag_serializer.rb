class RfidTagSerializer < ActiveModel::Serializer
  attributes :id,
             :rfid_number,
             :active,
             :last_scanned_at,
             :location_id,
             :created_at,
             :updated_at

  belongs_to :asset
  belongs_to :last_known_location, class_name: 'Location'
  has_many :asset_tracking_events
end 