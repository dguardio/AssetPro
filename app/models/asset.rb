class Asset < ApplicationRecord
  belongs_to :category
  belongs_to :location, optional: true
  has_many :asset_assignments, dependent: :destroy
  has_many :users, through: :asset_assignments
  has_many :maintenance_records, dependent: :destroy
  has_one :rfid_tag, dependent: :destroy
  has_many :asset_tracking_events, dependent: :destroy

  validates :name, presence: true
  validates :status, presence: true

  enum status: {
    available: 'available',
    in_use: 'in_use',
    in_maintenance: 'in_maintenance',
    retired: 'retired'
  }

  scope :active, -> { where.not(status: :retired) }
  scope :available, -> { where(status: 'available') }
  scope :in_use, -> { where(status: 'in_use') }
  scope :in_maintenance, -> { where(status: 'in_maintenance') }
  scope :retired, -> { where(status: 'retired') }
  scope :rfid_enabled, -> { where(rfid_enabled: true) }
  scope :needs_tracking, -> { rfid_enabled.where('last_tracked_at < ?', 24.hours.ago) }

  def current_assignment
    asset_assignments.where(checked_in_at: nil).first
  end

  def available?
    status == 'available'
  end

  def current_location
    asset_tracking_events.recent.first&.location
  end

  def tracking_history
    asset_tracking_events.recent
  end

  def assign_rfid_tag!(rfid_number)
    transaction do
      update!(rfid_enabled: true)
      create_rfid_tag!(
        rfid_number: rfid_number,
        active: true,
        last_known_location: location
      )
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    ["asset_code", "category_id", "created_at", "description", "id", 
     "location_id", "name", "rfid_enabled", "status", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["category", "location", "rfid_tag", "asset_tracking_events"]
  end
end
