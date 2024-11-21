class License < ApplicationRecord
  belongs_to :asset, optional: true
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
  
  private

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