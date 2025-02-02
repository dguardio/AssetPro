class AssetAssignment < ApplicationRecord
  acts_as_paranoid

  belongs_to :asset
  belongs_to :user 
  belongs_to :assigned_by, class_name: 'User', optional: true
  has_many :asset_tracking_events, dependent: :destroy

  validates :checked_out_at, presence: true
  validate :check_in_after_check_out
  validate :asset_available, on: :create
  validate :no_duplicate_active_assignments, on: :create

  before_create :update_asset_status
  before_update :handle_check_in, if: :checking_in?
  #validate :asset_available_for_checkout, on: :create

  before_destroy :check_if_ended
  before_destroy :check_if_checked_out
  before_destroy :unassign_asset

  after_create :create_assignment_event
  after_update :create_unassignment_event, if: :ended?

  after_commit :notify_assignment
  # after_commit :update_asset_status

  def self.ransackable_attributes(auth_object = nil)
    ["asset_id", "checked_in_at", "checked_out_at", "created_at", "id", "notes", 
     "updated_at", "user_id", "assigned_by_id", "deleted_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["asset", "user", "assigned_by"]
  end



  def self.ransortable_attributes(auth_object = nil)
    ransackable_attributes(auth_object) + [
      'asset_name',
      'user_email',
      'user_full_name',
      'assigned_by_email',
      'assigned_by_full_name'
    ]
  end

  def asset_name
    asset&.name
  end

  def user_email
    user&.email
  end

  def user_full_name
    user&.full_name
  end

  def assigned_by_email
    assigned_by&.email
  end

  def assigned_by_full_name
    assigned_by&.full_name
  end

  # Add ransacker for asset name
  ransacker :asset_name do |parent|
    Arel::Nodes::InfixOperation.new('ILIKE', 
      Arel::Nodes::NamedFunction.new('COALESCE', [
        parent.table.join(Asset.arel_table)
          .on(Asset.arel_table[:id].eq(parent.table[:asset_id]))
          .project(Asset.arel_table[:name])
      ]),
      Arel::Nodes::SqlLiteral.new("'%' || ? || '%'"))
  end

  # Add ransacker for user email
  ransacker :user_email do |parent|
    Arel::Nodes::InfixOperation.new('ILIKE',
      Arel::Nodes::NamedFunction.new('COALESCE', [
        parent.table.join(User.arel_table)
          .on(User.arel_table[:id].eq(parent.table[:user_id]))
          .project(User.arel_table[:email])
      ]),
      Arel::Nodes::SqlLiteral.new("'%' || ? || '%'"))
  end

  # Status helper method
  def status
    if checked_in_at.present?
      'checked_in'
    else
      'checked_out'
    end
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
    will_save_change_to_checked_in_at? && 
    checked_in_at.present? && 
    checked_in_at_was.nil?
  end

  def handle_check_in
    return unless checking_in?
    Rails.logger.info "Handling check-in for asset #{asset.id}"
    
    begin
      asset.update!(status: :available)
      AssetAssignmentNotifier.checked_in(self)
    rescue StandardError => e
      Rails.logger.error "Check-in failed: #{e.message}\n#{e.backtrace.join("\n")}"
      errors.add(:base, "Failed to check in asset: #{e.message}")
      raise e
    end
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
    return unless checking_in?
    Rails.logger.info "Creating unassignment event for asset #{asset.id}"
    
    begin
      asset.asset_tracking_events.create!(
        event_type: :unassigned,
        location: asset&.current_location,
        scanned_by: assigned_by,
        asset_assignment: self,
        rfid_number: asset&.rfid_tag&.rfid_number,
        scanned_at: DateTime.now
      )
    rescue StandardError => e
      Rails.logger.error "Unassignment event creation failed: #{e.message}\n#{e.backtrace.join("\n")}"
      errors.add(:base, "Failed to create unassignment event: #{e.message}")
      raise e
    end
  end

  def ended?
    saved_change_to_checked_in_at? && 
    checked_in_at.present? && 
    checked_in_at_previously_was.nil?
  end

  def unassign_asset
    if checked_in_at.nil?
      asset.update!(status: :available)
    end
  end

  def no_duplicate_active_assignments
    if AssetAssignment.where(asset_id: asset_id)
                     .where(checked_in_at: nil)
                     .where.not(id: id)
                     .exists?
      errors.add(:base, "This asset already has an active assignment")
    end
  end
end