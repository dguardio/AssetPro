class Asset < ApplicationRecord
  include QrCodeable
  include Auditable
  include Importable
  acts_as_paranoid
  
  belongs_to :category
  belongs_to :location, optional: true
  has_many :asset_assignments, dependent: :destroy
  has_many :users, through: :asset_assignments
  has_many :maintenance_records, dependent: :destroy
  has_one :rfid_tag, dependent: :nullify
  has_many :asset_tracking_events, dependent: :destroy
  has_many :maintenance_schedules
  has_many :licenses
  has_many :audit_logs, as: :auditable, dependent: :destroy
  has_many :asset_requests, dependent: :destroy
  has_many :asset_licenses, dependent: :destroy
  has_many :licenses, through: :asset_licenses


  before_destroy :cleanup_rfid_tag

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

  scope :without_deleted, -> { where(deleted_at: nil) }

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
    return 0 unless valid_for_valuation?
    
    # Calculate age in years (including partial years)
    age_in_years = (Date.current - purchase_date).to_f / 365.25
    
    if useful_life_years.present?
      # Straight-line depreciation with salvage value
      if age_in_years >= useful_life_years
        (salvage_value || 0) * quantity
      else
        depreciation_per_year = (purchase_price - (salvage_value || 0)) / useful_life_years
        current_single_value = purchase_price - (depreciation_per_year * age_in_years)
        (current_single_value * quantity).round(2)
      end
    else
      # Fallback to declining balance method if no useful life specified
      depreciation_multiplier = 1 - (depreciation_rate || 0) / 100
      value = purchase_price * (depreciation_multiplier ** age_in_years)
      (value * quantity).round(2)
    end
  end

  def annual_cost_of_ownership
    # Combines all yearly costs
    [
      maintenance_cost_yearly || 0,
      annual_depreciation,
      insurance_cost
    ].sum.round(2)
  end

  def total_purchase_value
    purchase_price ? (purchase_price * quantity) : 0
  end

  def next_maintenance
    maintenance_schedules.upcoming.order(next_due_at: :asc).first
  end

  def warranty_status
    return 'No Warranty' if warranty_expiry_date.nil?
    
    if warranty_expiry_date < Date.current
      'Expired'
    elsif warranty_expiry_date < 30.days.from_now
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
  after_save :notify_status_change

  def available_quantity
    quantity - asset_assignments.where(checked_in_at: nil).count
  end

  def low_stock?
    available_quantity <= minimum_quantity
  end

  def self.find_or_create_category(name)
    return nil if name.blank?
    
    # First try to find including soft-deleted categories
    category = Category.with_deleted.find_by(name: name)
    
    if category&.deleted?
      # If category exists but is soft-deleted, restore it
      category.restore
      category
    elsif category
      # If category exists and is not deleted, use it
      category
    else
      # If category doesn't exist, create it
      Category.create!(name: name)
    end
  rescue ActiveRecord::RecordInvalid => e
    raise ImportError, "Invalid category: #{e.message}"
  end

  def self.find_or_create_location(name)
    return nil if name.blank?
    
    # First try to find including soft-deleted locations
    location = Location.with_deleted.find_by(name: name)
    
    if location&.deleted?
      # If location exists but is soft-deleted, restore it
      location.restore
      location
    elsif location
      # If location exists and is not deleted, use it
      location
    else
      # If location doesn't exist, create it
      Location.create!(name: name, address: 'Address pending')
    end
  rescue ActiveRecord::RecordInvalid => e
    raise ImportError, "Invalid location: #{e.message}"
  end

  def self.generate_import_message(imported_assets, skipped_assets)
    message = []
    
    if imported_assets.any?
      message << "Successfully imported #{imported_assets.count} assets:"
      message << imported_assets.join("\n")
    end
    
    if skipped_assets.any?
      message << "\nSkipped #{skipped_assets.count} assets:"
      message << skipped_assets.map { |msg| "• #{msg}" }.join("\n")
    end
    
    message.join("\n")
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    skipped_assets = []
    imported_assets = []
    
    transaction do
      (2..spreadsheet.last_row).each do |i|
        begin
          row = Hash[[header, spreadsheet.row(i)].transpose]
          
          # Check for existing asset before trying to create
          if Asset.exists?(asset_code: row['asset_code'])
            skipped_assets << "Asset code '#{row['asset_code']}' already exists (Row #{i})"
            next
          end
          
          if Asset.exists?(name: row['name'])
            skipped_assets << "Asset name '#{row['name']}' already exists (Row #{i})"
            next
          end

          # Find or create category and location
          category = find_or_create_category(row['category'])
          location = find_or_create_location(row['location'])

          unless category
            skipped_assets << "Invalid or missing category '#{row['category']}' (Row #{i})"
            next
          end

          unless location
            skipped_assets << "Invalid or missing location '#{row['location']}' (Row #{i})"
            next
          end

          asset = Asset.create!(
            name: row['name'],
            asset_code: row['asset_code'],
            category_id: category.id,
            location_id: location.id,
            status: row['status'].presence || 'available',
            description: row['description'],
            purchase_date: row['purchase_date'],
            purchase_price: row['purchase_price']
          )
          
          imported_assets << "#{asset.display_name} (#{asset.asset_code})"
        rescue StandardError => e
          error_message = case e
          when ActiveRecord::RecordNotUnique
            "Duplicate asset code or name (Row #{i})"
          when ActiveRecord::RecordInvalid
            e.record.errors.full_messages.join(', ') + " (Row #{i})"
          when PG::Error
            "Database error: Please try again (Row #{i})"
          else
            "Error: #{e.message.gsub(/PG::.*?ERROR:/, '').strip} (Row #{i})"
          end
          skipped_assets << error_message
          raise ActiveRecord::Rollback
        end
      end
    end

    {
      success: imported_assets.any?,
      imported_assets: imported_assets,
      skipped_assets: skipped_assets,
      message: generate_import_message(imported_assets, skipped_assets)
    }
  end

  def display_name
    return '' if name.blank?
    name.split.map(&:capitalize).join(' ')
  end

  private

  def check_stock_level
    return unless should_notify_stock_level?
    
    if available_quantity <= 0
      LowStockNotifier.out_of_stock(self)
    elsif available_quantity <= minimum_quantity
      LowStockNotifier.minimum_reached(self)
    end
  end

  def should_notify_stock_level?
    return false unless status_changed?
    return false if status.nil?
    ['retired', 'in_maintenance'].include?(status)
  end

  def valid_for_valuation?
    purchase_price.present? && purchase_date.present? && 
    (useful_life_years.present? || depreciation_rate.present?)
  end

  def annual_depreciation
    return 0 unless valid_for_valuation?
    return 0 if age_in_years >= useful_life_years

    if useful_life_years.present?
      (purchase_price - (salvage_value || 0)) / useful_life_years
    else
      purchase_price * (depreciation_rate || 0) / 100
    end
  end

  def insurance_cost
    insurance_value.present? ? (insurance_value / 12) : 0
  end

  def age_in_years
    @age_in_years ||= (Date.current - purchase_date).to_f / 365.25
  end

  def notify_status_change
    return unless saved_change_to_status?
    AssetStatusNotifier.status_changed(self, RequestStore.store[:current_user])
  end
  
  def cleanup_rfid_tag
    if rfid_tag.present?
      rfid_tag.update!(
        asset_id: nil,
        active: false
      )
      update_column(:rfid_enabled, false)
      RfidNotifier.tag_deactivated(self)
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when '.csv' then Roo::CSV.new(file.path)
    when '.xlsx' then Roo::Excelx.new(file.path)
    when '.xls' then Roo::Excel.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
end
