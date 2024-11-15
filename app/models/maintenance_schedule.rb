class MaintenanceSchedule < ApplicationRecord
  belongs_to :asset
  belongs_to :assigned_to, class_name: 'User', optional: true
  
  enum status: {
    scheduled: 0,
    in_progress: 1,
    completed: 2,
    overdue: 3
  }
  
  validates :title, presence: true
  validates :scheduled_date, presence: true
  
  scope :upcoming, -> { where('scheduled_date > ? AND scheduled_date < ?', Time.current, 30.days.from_now) }
  scope :overdue, -> { where('scheduled_date < ? AND status != ?', Time.current, 2) }

  after_save :check_and_notify

  private

  def check_and_notify
    return unless should_send_notification?
    
    recipients = [assigned_to, asset.users.first].compact
    
    MaintenanceDueNotification.with(
      maintenance_schedule: self
    ).deliver_later(recipients)
  end

  def should_send_notification?
    return true if scheduled_date_previously_changed? && upcoming?
    return true if status_previously_changed? && overdue?
    false
  end

  def upcoming?
    scheduled_date.between?(Time.current, 7.days.from_now)
  end

  def overdue?
    scheduled_date < Time.current && !completed?
  end
end 