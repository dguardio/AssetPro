class AssetTrackingEvent < ApplicationRecord
  belongs_to :asset
  belongs_to :location
  belongs_to :asset_assignment, optional: true
  belongs_to :scanned_by, class_name: 'User'
  belongs_to :previous_location, class_name: 'Location', optional: true
  belongs_to :oauth_application, class_name: 'Doorkeeper::Application', optional: true
  # belongs_to :organization
  # belongs_to :sub_organization, optional: true
  belongs_to :scanned_by_device, class_name: 'RfidReader', foreign_key: 'rfid_reader_id', optional: true

  # Define event types enum
  enum event_type: {
    movement: 'movement',        # RFID movement detection
    check_in: 'check_in',       # Physical location check-in
    check_out: 'check_out',     # Physical location check-out
    assigned: 'assigned',       # Asset assigned to user
    unassigned: 'unassigned',   # Asset unassigned from user
    transfer: 'transfer',
    inventory: 'inventory',
    maintenance: 'maintenance',
  }

  def event_type_badge_color
    case event_type
    when 'movement'
      'info'
    when 'check_out'
      'warning'
    when 'check_in'
      'success'
    when 'assigned'
      'primary'   # Blue color for assignments
    when 'unassigned'
      'secondary' # Gray color for unassignments
    else
      'secondary'
    end
  end
 

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

  # def previous_event
  #   asset.asset_tracking_events
  #        .where('scanned_at < ?', scanned_at)
  #        .order(scanned_at: :desc)
  #        .first
  # end
  # 

  def self.create_assignment_event(asset:, user:, assigned_by:, location:)
    create!(
      event_type: :assigned,
      asset: asset,
      user: user,              # The user receiving the asset
      created_by: assigned_by, # The admin/manager doing the assignment
      location: location,
      notes: "Assigned to #{user.full_name}"
    )
  end

  def self.create_unassignment_event(asset:, user:, unassigned_by:, location:)
    create!(
      event_type: :unassigned,
      asset: asset,
      user: user,                # The user returning the asset
      created_by: unassigned_by, # The admin/manager handling the return
      location: location,
      notes: "Unassigned from #{user.full_name}"
    )
  end

  # Add this scope
  scope :recent, -> { order(created_at: :desc) }

  before_save :set_organization_names
  
  private

  def set_organization_names
    if oauth_application
      self.organization_id = oauth_application.organization_id
      self.sub_organization_id = oauth_application.sub_organization_id
      self.organization_name = oauth_application.organization_name
      self.sub_organization_name = oauth_application.sub_organization_name
    end
  end
end 