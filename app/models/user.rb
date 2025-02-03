class User < ApplicationRecord
  # acts_as_paranoid
  rolify

  include Auditable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable, :lockable

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true, inclusion: { in: %w[admin manager user security] }

  # Associations
  has_many :asset_assignments
  has_many :assigned_assets, through: :asset_assignments, source: :asset
  has_many :asset_requests
  has_many :account_status_logs
  has_many :audit_logs
  has_many :notifications, as: :recipient, dependent: :destroy, class_name: 'Noticed::Notification'

  # Callbacks
  after_create :assign_default_role

  # Instance methods
  def name
    "#{first_name} #{last_name}".strip
  end
  alias_method :full_name, :name

  def admin?
    role == 'admin'
  end

  def security?
    role == 'security'
  end

  def manager?
    role == 'manager'
  end

  def user?
    role == 'user'
  end

  # Optional: A more dynamic approach if you need to check roles frequently
  def has_role?(role_name)
    role == role_name.to_s
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[email first_name last_name name role active created_at updated_at locked_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[account_status_logs asset_assignments assigned_assets audit_logs notifications roles]
  end

  def self.available_roles
    %w[admin manager user security]  # Define available roles
  end

  def current_role
    roles.first&.name || 'user'
  end

  def profile_reset?
    false  # Default to false since this is for the regular password reset flow
  end

  def send_lock_notification(reason)
    send_devise_notification(:lock, reason)
  end

  private

  def assign_default_role
    # Skip the callback during seeding
    return if Rails.env.development? && caller.any? { |c| c.include?('seed.rb') }
    
    # Add default role if no roles exist
    add_role(:user) if roles.blank?
  end
end
