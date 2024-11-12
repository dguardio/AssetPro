class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  has_many :asset_assignments
  has_many :assets, through: :asset_assignments
  has_many :account_status_logs

  enum role: {
    user: 'user',
    admin: 'admin',
    security: 'security',
    manager: 'manager'
  }

  validates :role, presence: true

  after_initialize :set_default_role, if: :new_record?

  # Example roles you might want to add
  after_create :assign_default_role

  # Add callback to handle user deactivation
  after_update :handle_deactivation, if: :saved_change_to_active?

  def admin?
    role == 'admin'
  end

  def security?
    role == 'security'
  end

  def manager?
    role == 'manager'
  end

  def full_name
    return email if first_name.blank? && last_name.blank?
    [first_name, last_name].compact.join(' ')
  end

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :deactivated_account
  end

  def deactivate!(changed_by:, reason: nil)
    return false unless active?
    
    User.transaction do
      account_status_logs.create!(
        changed_by: changed_by,
        status_from: true,
        status_to: false,
        reason: reason
      )
      update!(active: false)
    end
  end

  def activate!(changed_by:, reason: nil)
    return false if active?
    
    User.transaction do
      account_status_logs.create!(
        changed_by: changed_by,
        status_from: false,
        status_to: true,
        reason: reason
      )
      update!(active: true)
    end
  end

  private

  def assign_default_role
    self.add_role(:employee) if self.roles.blank?
  end

  def set_default_role
    self.role ||= :user
  end

  def handle_deactivation
    if !active? && (Devise.sign_out_all_scopes ? Devise.sign_out_all_scopes : sign_out_all_scopes)
      # Force logout all sessions for this user
      Rails.application.config.session_store.new(Rails.application).destroy_session_by_user(self)
    end
  end
end
