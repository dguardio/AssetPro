class MaintenanceSchedule < ApplicationRecord
  acts_as_paranoid

  has_many :maintenance_records, dependent: :destroy
  belongs_to :asset
  belongs_to :assigned_to, class_name: 'User', optional: true
  
  enum status: {
    pending: 'pending',
    in_progress: 'in_progress',
    completed: 'completed',
    overdue: 'overdue',
    cancelled: 'cancelled'
  }
  
  validates :title, presence: true
  validates :frequency, presence: true
  validates :next_due_at, presence: true
  validates :status, presence: true
  
  scope :upcoming, -> { where(status: [:pending, :in_progress]).where('next_due_at > ?', Time.current) }
  scope :overdue, -> { where('next_due_at < ?', Time.current) }
  scope :without_deleted, -> { where(deleted_at: nil) }

  after_save :check_and_notify
  after_save :notify_completion

  def self.ransackable_attributes(auth_object = nil)
    ["asset_id", "assigned_to_id", "created_at", "description", "frequency", 
     "id", "last_performed_at", "next_due_at", "status", "title", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["asset", "assigned_to"]
  end

  def self.frequencies
    {
      daily: 'daily',
      weekly: 'weekly',
      monthly: 'monthly',
      quarterly: 'quarterly',
      semi_annual: 'semi_annual',
      annual: 'annual',
      one_time: 'one_time',
      custom: 'custom'
    }
  end

  before_validation :set_initial_status
  
  def status_badge_color
    case status
    when 'pending' then 'info'
    when 'in_progress' then 'primary'
    when 'completed' then 'success'
    when 'overdue' then 'danger'
    when 'cancelled' then 'secondary'
    else 'secondary'
    end
  end

  def calculate_next_due_date
    return nil unless next_due_at && frequency
    return nil if frequency == 'one_time'  # No next date for one-time schedules

    case frequency
    when 'daily'
      1.day.from_now
    when 'weekly'
      1.week.from_now
    when 'monthly'
      1.month.from_now
    when 'quarterly'
      3.months.from_now
    when 'semi_annual'
      6.months.from_now
    when 'annual'
      1.year.from_now
    else
      next_due_at # for custom frequency, keep the original date
    end
  end

  def update_next_due_date
    return if frequency == 'custom'
    
    self.last_performed_at = Time.current
    
    if frequency == 'one_time'
      self.status = 'completed'  # Keep it completed for one-time schedules
    else
      self.next_due_at = calculate_next_due_date
      self.status = 'pending'  # Reset status to pending for recurring schedules
    end
    
    save
  end

  before_save :check_overdue_status

  def overdue?
    next_due_at.present? && next_due_at < Time.current
  end

  def due_soon?
    return false unless next_due_at.present?
    
    warning_window = case frequency
      when 'daily'
        12.hours
      when 'weekly'
        2.days
      when 'monthly'
        5.days
      when 'quarterly'
        14.days
      when 'semi_annual'
        21.days
      when 'annual'
        30.days
      else
        7.days # default for custom frequency
    end

    next_due_at.between?(Time.current, Time.current + warning_window)
  end

  def upcoming?
    next_due_at.between?(Time.current, 7.days.from_now)
  end

  private

  def set_initial_status
    # Don't override status if it's already set and valid
    return if status.present? && self.class.statuses.key?(status)
    
    self.status = if frequency == 'one_time'
      next_due_at&.past? ? 'overdue' : 'pending'
    else
      if next_due_at&.past?
        'overdue'
      else
        'pending'
      end
    end
  end

  def check_and_notify
    return unless should_send_notification?
    
    recipients = [assigned_to, asset.users.first].compact
    
    MaintenanceDueNotifier.with(
      maintenance_schedule: self,
      notification_type: :maintenance_due
    ).deliver_later(recipients)
  end

  def should_send_notification?
    return true if next_due_at_previously_changed? && upcoming?
    return true if status_previously_changed? && overdue?
    false
  end

  def notify_completion
    return unless saved_change_to_status? && status == 'completed'
    MaintenanceDueNotifier.maintenance_completed(self)
  end

  def check_overdue_status
    return unless next_due_at_changed? || status_changed?
    return if frequency == 'one_time' && completed?  # Don't mark completed one-time schedules as overdue
    return if status == 'cancelled'  # Don't mark cancelled schedules as overdue
    
    if next_due_at.present? && next_due_at < Time.current && !completed?
      self.status = 'overdue'
    end
  end
end 