class AccountStatusLog < ApplicationRecord
  belongs_to :user
  belongs_to :changed_by, class_name: 'User'

  validates :status_from, :status_to, presence: true
  validates :reason, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
