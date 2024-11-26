class AssetTrackingEvent < ApplicationRecord
  belongs_to :asset
  belongs_to :location
  belongs_to :scanned_by, class_name: 'User'

  # Define event types enum
  enum event_type: {
    check_in: 'check_in',
    check_out: 'check_out',
    transfer: 'transfer',
    inventory: 'inventory',
    maintenance: 'maintenance'
  }

  # Validations
  validates :event_type, presence: true
  validates :rfid_number, presence: true
  validates :scanned_at, presence: true

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    ["asset_id", "created_at", "event_type", "id", "location_id", 
     "rfid_number", "scanned_at", "scanned_by_id", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["asset", "location", "scanned_by"]
  end
end 