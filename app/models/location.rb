class Location < ApplicationRecord
  scope :active, -> { where(active: true) }
  has_many :assets, dependent: :restrict_with_error
  has_many :rfid_tags, dependent: :restrict_with_error

  validates :name, presence: true
  validates :address, presence: true

  def full_location
    [building, floor, room].compact.join(' - ')
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "building", "floor", "room", "address", "created_at", "updated_at"]
  end
end
