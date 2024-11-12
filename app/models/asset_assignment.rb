class AssetAssignment < ApplicationRecord
  belongs_to :asset
  belongs_to :user

  validates :checked_out_at, presence: true
  validate :check_in_after_check_out
  validate :asset_available, on: :create

  before_create :update_asset_status
  before_update :handle_check_in, if: :checking_in?

  private

  def check_in_after_check_out
    return unless checked_in_at.present? && checked_out_at.present?
    if checked_in_at < checked_out_at
      errors.add(:checked_in_at, "must be after check-out time")
    end
  end

  def asset_available
    return unless asset
    unless asset.available?
      errors.add(:asset, "is not available for checkout")
    end
  end

  def update_asset_status
    asset.update(status: :checked_out)
  end

  def checking_in?
    checked_in_at_changed? && checked_in_at.present?
  end

  def handle_check_in
    asset.update(status: :available)
  end
end
