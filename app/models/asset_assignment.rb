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
  end

  def checking_in?
    checked_in_at_changed? && checked_in_at.present?
  end

  def handle_check_in
    asset.update(status: :available)
  end

  def notify_assignment
    AssetAssignmentNotifier.with(
      asset_assignment: self
    ).deliver(user)
  end

  def create_assignment_event
    asset.asset_tracking_events.create!(
      event_type: :assigned,
      location: asset.current_location,
      scanned_by: assigned_by,
      asset_assignment: self,
      rfid_number: asset.rfid_tag.rfid_number,
      scanned_at: DateTime.now
    )
  end

  def create_unassignment_event
    asset.asset_tracking_events.create!(
      event_type: :unassigned,
      location: asset.current_location,
      scanned_by: assigned_by,
      asset_assignment: self,
      rfid_number: asset.rfid_tag.rfid_number,
      scanned_at: DateTime.now
    )
  end

  def ended?
    saved_change_to_ended_at? && ended_at.present?
  end
end
