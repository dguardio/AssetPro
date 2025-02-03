class RfidTag < ApplicationRecord
  acts_as_paranoid

  belongs_to :asset, optional: true
  belongs_to :last_known_location, class_name: 'Location', foreign_key: 'location_id', optional: true
  belongs_to :location, optional: true

  has_many :asset_tracking_events, foreign_key: 'rfid_number', primary_key: 'rfid_number'
  
  validates :rfid_number, presence: true, uniqueness: { conditions: -> { with_deleted } }
  validates :active, inclusion: { in: [true, false] }
  
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :without_deleted, -> { where(deleted_at: nil) }
  
  def deactivate!
    update!(active: false)
  end
  
  def activate!
    update!(active: true)
  end
  
  def self.ransackable_attributes(auth_object = nil)
    ["active", "asset_id", "created_at", "id", "last_scanned_at", "location_id", "rfid_number", "updated_at", "deleted_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["asset", "location"]
  end
end 