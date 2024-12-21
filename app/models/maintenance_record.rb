class MaintenanceRecord < ApplicationRecord
  acts_as_paranoid

  belongs_to :asset
  belongs_to :performed_by, class_name: 'User'
  belongs_to :maintenance_schedule, optional: true

  validates :maintenance_type, presence: true
  validates :description, presence: true
  validates :scheduled_date, presence: true

  before_create :update_asset_status
  after_update :handle_completion, if: :completed?

  enum maintenance_type: {
    preventive: 'preventive',
    corrective: 'corrective',
    inspection: 'inspection'
  }

  def self.ransackable_attributes(auth_object = nil)
    ["asset_id", "cost", "created_at", "description", "id", "maintenance_date", 
     "maintenance_schedule_id", "performed_by_id", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["asset", "maintenance_schedule", "performed_by"]
  end

  private

  def update_asset_status
    asset.update(status: :in_maintenance)
  end

  def completed?
    completed_date_changed? && completed_date.present?
  end

  def handle_completion
    asset.update(status: :available)
  end
end
