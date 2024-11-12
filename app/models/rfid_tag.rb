class RfidTag < ApplicationRecord
  belongs_to :asset
  belongs_to :last_known_location, class_name: 'Location', foreign_key: 'location_id'
  
  has_many :asset_tracking_events, foreign_key: 'rfid_number', primary_key: 'rfid_number'
  
  validates :rfid_number, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
  
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  
  def deactivate!
    update!(active: false)
  end
  
  def activate!
    update!(active: true)
  end
  
  def self.ransackable_attributes(auth_object = nil)
    ["id", "rfid_number", "active", "asset_id", "last_known_location_id", "created_at", "updated_at"]
  end
end 