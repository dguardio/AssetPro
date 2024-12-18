class MaintenanceSchedule < ApplicationRecord
  belongs_to :asset
  belongs_to :assigned_to, class_name: 'User', optional: true
  
  enum status: {
    pending: 0,
    in_progress: 1,
    completed: 2,
    overdue: 3,
    cancelled: 4
  }
  
  validates :title, presence: true
  validates :frequency, presence: true
  validates :next_due_at, presence: true
  validates :status, presence: true
  
  scope :upcoming, -> { where(status: [:pending, :in_progress]).where('next_due_at > ?', Time.current) }
  scope :overdue, -> { where('next_due_at < ?', Time.current) }

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
      custom: 'custom'
    }
  end

  before_create :set_initial_status
  
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

  private

  def set_initial_status
    self.status ||= 'pending'
  end

  def check_and_notify
    return unless should_send_notification?
    
    recipients = [assigned_to, asset.users.first].compact
    
    MaintenanceDueNotification.with(
      maintenance_schedule: self
    ).deliver_later(recipients)
  end

  def should_send_notification?
    return true if next_due_at_previously_changed? && upcoming?
    return true if status_previously_changed? && overdue?
    false
  end

  def upcoming?
    next_due_at.between?(Time.current, 7.days.from_now)
  end

  def due_soon?
    next_due_at.present? && next_due_at < 7.days.from_now && next_due_at > Time.current
  end

  def overdue?
    next_due_at.present? && next_due_at < Time.current
  end

  def notify_completion
    return unless saved_change_to_status? && status == 'completed'
    
    recipients = [asset.users.first, assigned_to].compact + User.with_role(:manager)
    
    MaintenanceCompletedNotification.with(
      maintenance_schedule: self,
      completed_by: RequestStore.store[:current_user]
    ).deliver_later(recipients)
  end
end 