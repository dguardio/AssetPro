class AssetRequest < ApplicationRecord
  acts_as_paranoid
  
  belongs_to :user
  belongs_to :asset
  belongs_to :reviewed_by, class_name: 'User', optional: true

  validates :purpose, presence: true
  validates :requested_from, presence: true
  validates :requested_until, presence: true
  validate :valid_date_range
  validate :asset_availability

  enum status: {
    pending: 'pending',
    approved: 'approved',
    rejected: 'rejected',
    cancelled: 'cancelled'
  }

  after_create :notify_managers
  after_update :notify_status_change, if: :saved_change_to_status?

  def self.ransackable_attributes(auth_object = nil)
    ["asset_id", "created_at", "deleted_at", "id", "purpose", 
     "rejection_reason", "requested_from", "requested_until", 
     "reviewed_at", "reviewed_by_id", "status", "updated_at", "user_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["asset", "user", "reviewed_by"]
  end

  def notify_managers
    User.with_role(:manager).each do |manager|
      AssetRequestNotifier.new_request(self).deliver_later(manager)
    end
  end

  def notify_status_change
    AssetRequestNotifier.status_changed(self)
  end  

  private

  def valid_date_range
    return unless requested_from && requested_until
    if requested_until <= requested_from
      errors.add(:requested_until, "must be after the start date")
    end
  end

  def asset_availability
    return unless asset && requested_from && requested_until

    # Check if asset is available for requests
    unless asset.available?
      errors.add(:base, "Asset is not available for requests (current status: #{asset.status})")
      return
    end

    # Check for existing assignments during the requested period
    conflicting_assignment = asset.asset_assignments
      .where('checked_out_at <= ? AND (checked_in_at IS NULL OR checked_in_at >= ?)', 
             requested_until, requested_from)
      .exists?

    if conflicting_assignment
      errors.add(:base, "Asset is already assigned during the requested period")
      return
    end

    # Check for approved requests during the requested period
    conflicting_request = asset.asset_requests
      .approved
      .where.not(id: id)
      .where('requested_from <= ? AND requested_until >= ?', 
             requested_until, requested_from)
      .exists?

    if conflicting_request
      errors.add(:base, "Asset is already approved for another request during this period")
    end
  end

end 