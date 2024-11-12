class AssetTrackingEvent < ApplicationRecord
  belongs_to :asset
  belongs_to :location
  belongs_to :scanned_by, class_name: 'User'

  validates :event_type, presence: true
  validates :rfid_number, presence: true
end 