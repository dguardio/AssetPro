class License < ApplicationRecord
  acts_as_paranoid
  
  has_many :asset_licenses, dependent: :destroy
  has_many :assets, through: :asset_licenses
  belongs_to :assigned_to, class_name: 'User', optional: true
  
  validates :name, presence: true
  validates :seats, numericality: { greater_than: 0 }
  validates :expiration_date, presence: true
  
  scope :expiring_soon, -> { where('expiration_date > ? AND expiration_date < ?', Time.current, 30.days.from_now) }
  scope :expired, -> { where('expiration_date < ?', Time.current) }

  after_save :check_expiration
  
  def self.ransackable_attributes(auth_object = nil)
    ["asset_id", "cost", "created_at", "expiration_date", "id", "license_key", 
     "name", "notes", "seats", "supplier", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["asset"]
  end
  
  def current_value
    return 0 unless cost.present? && valid_dates?
    
    if perpetual?
      total_value
    elsif expired?
      0
    else
      remaining_value = calculate_remaining_value
      remaining_value.round(2)
    end
  end

  def total_value
    return 0 unless cost.present?
    cost * seats
  end

  def seats_used
    asset_licenses.count
  end

  def seats_available
    return 0 if seats.nil?
    seats - seats_used
  end

  def available_for_assignment?
    !expired? && seats_available > 0
  end

  def utilization_rate
    return 0 if seats.nil? || seats.zero?
    (seats_used.to_f / seats * 100).round(2)
  end

  private

  def valid_dates?
    purchase_date.present? && (perpetual? || expiration_date.present?)
  end

  def perpetual?
    expiration_date.nil?
  end

  def expired?
    expiration_date&.past?
  end

  def calculate_remaining_value
    total_days = (expiration_date - purchase_date).to_i
    remaining_days = (expiration_date - Date.current).to_i
    
    # Linear amortization of license value
    value_per_seat = cost * (remaining_days.to_f / total_days)
    value_per_seat * seats
  end

  def check_expiration
    return unless should_notify_expiration?
    
    # Notify all admins about expiring licenses
    recipients = User.admins

    LicenseExpiringNotification.with(
      license: self
    ).deliver_later(recipients)
  end

  def should_notify_expiration?
    return false if expiration_date.nil?
    days_until_expiration = (expiration_date.to_date - Date.current).to_i
    days_until_expiration.between?(0, 30)
  end
end 
