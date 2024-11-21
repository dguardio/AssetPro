class Asset < ApplicationRecord
  include QrCodeable
  include Auditable
  include Importable
  
  belongs_to :category
  belongs_to :location, optional: true
  has_many :asset_assignments, dependent: :destroy
  has_many :users, through: :asset_assignments
  has_many :maintenance_records, dependent: :destroy
  has_one :rfid_tag, dependent: :destroy
  has_many :asset_tracking_events, dependent: :destroy
  has_many :maintenance_schedules
  has_many :licenses
  has_many :audit_logs, as: :auditable, dependent: :destroy


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
    ["category", "location", "rfid_tag", 
    "asset_tracking_events", "asset_assignments", 
    "licenses", "location", "maintenance_records", 
    "maintenance_schedules"]
  end

  def current_value
    return 0 if purchase_price.nil?
    return purchase_price if purchase_date.nil? || depreciation_rate.nil?
    
    age_in_years = (Time.current.to_date - purchase_date).to_f / 365
    depreciated_value = purchase_price * (1 - (depreciation_rate * age_in_years))
    [depreciated_value, 0].max
  end
  
  def next_maintenance
    maintenance_schedules.upcoming.order(scheduled_date: :asc).first
  end

  def warranty_status
    return 'No Warranty' if warranty_expiry.nil?
    
    if warranty_expiry < Date.current
      'Expired'
    elsif warranty_expiry < 30.days.from_now
      'Expiring Soon'
    else
      'Active'
    end
  end

  def warranty_status_color
    case warranty_status
    when 'Expired' then 'danger'
    when 'Expiring Soon' then 'warning'
    when 'Active' then 'success'
    else 'secondary'
    end
  end

  after_save :check_stock_level

  def available_quantity
    quantity - asset_assignments.where(checked_in_at: nil).count
  end

  def low_stock?
    available_quantity <= minimum_quantity
  end

  private

  def check_stock_level
    return unless should_notify_stock_level?
    
    recipients = User.admins

    LowStockNotification.with(
      asset: self
    ).deliver_later(recipients)
  end

  def should_notify_stock_level?
    return false unless status_changed?
    return false if status.nil?
    ['retired', 'in_maintenance'].include?(status)
  end
end
