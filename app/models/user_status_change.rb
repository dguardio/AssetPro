class UserStatusChange < ApplicationRecord
  belongs_to :user
  belongs_to :changed_by, class_name: 'User'

  validates :status_from, :status_to, presence: true
end 