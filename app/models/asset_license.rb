class AssetLicense < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :asset
  belongs_to :license
  
  validates :asset_id, uniqueness: { scope: :license_id }
  validate :license_has_available_seats, on: :create
  
  private
  
  def license_has_available_seats
    return unless license
    if license.seats_used >= license.seats
      errors.add(:base, "No available seats for this license")
    end
  end
end 