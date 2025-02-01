class AssetAssignment < ApplicationRecord
  acts_as_paranoid

  belongs_to :asset
  belongs_to :user 
  belongs_to :assigned_by, class_name: 'User', optional: true
  has_many :asset_tracking_events, dependent: :destroy

  validates :checked_out_at, presence: true
  validate :check_in_after_check_out
  validate :asset_available, on: :create

  before_create :update_asset_status
  before_update :handle_check_in, if: :checking_in?
  #validate :asset_available_for_checkout, on: :create

  before_destroy :check_if_ended
  before_destroy :check_if_checked_out
  before_destroy :unassign_asset

  after_create :create_assignment_event
  after_update :create_unassignment_event, if: :ended?

  after_commit :notify_assignment
  after_commit :update_asset_status

  def self.ransackable_attributes(auth_object = nil)
    ["asset_id", "checked_in_at", "checked_out_at", "created_at", "id", "notes", "updated_at", "user_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["asset", "user", "assigned_by"]
  end

  def self.ransortable_attributes(auth_object = nil)
    ransackable_attributes(auth_object) + ['asset_name', 'user_email']
  end

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
    asset.update!(status: 'in_use') if checked_in_at.nil?
  rescue StandardError => e
    errors.add(:base, "Failed to update asset status: #{e.message}")
    raise e
  end

  def checking_in?
    checked_in_at_changed? && checked_in_at.present?
  end

  def handle_check_in
    asset.update(status: :available)
  end

  def notify_assignment
    AssetAssignmentNotifier.assignment_created(self)
  end

  def notify_status_change
    case status
    when 'checked_out'
      AssetAssignmentNotifier.checked_out(self)
    when 'checked_in'
      AssetAssignmentNotifier.checked_in(self)
    end
  end

  def create_assignment_event
    asset.asset_tracking_events.create!({
      event_type: :assigned,
      location: asset&.location || asset&.current_location,
      scanned_by: assigned_by,
      asset_assignment: self,
      rfid_number: asset&.rfid_tag&.rfid_number,
      scanned_at: DateTime.now
    })
  rescue StandardError => e
    errors.add(:base, "Failed to create tracking event: #{e.message}")
    raise e
  end

  def create_unassignment_event
    asset.asset_tracking_events.create!(
      event_type: :unassigned,
      location: asset&.current_location,
      scanned_by: assigned_by,
      asset_assignment: self,
      rfid_number: asset&.rfid_tag&.rfid_number,
      scanned_at: DateTime.now
    )
  end

  def ended?
    saved_change_to_ended_at? && ended_at.present?
  end

  def unassign_asset
    if checked_in_at.nil?
      asset.update!(status: :available)
    end
  end
end