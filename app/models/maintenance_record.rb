class MaintenanceRecord < ApplicationRecord
  belongs_to :asset

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
