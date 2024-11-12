class RecentActivity < ApplicationRecord
  belongs_to :user
  belongs_to :trackable, polymorphic: true

  scope :recent, -> { order(created_at: :desc).limit(10) }
end 