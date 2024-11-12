class Category < ApplicationRecord
  has_many :assets

  validates :name, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "description", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["assets"]
  end
end
