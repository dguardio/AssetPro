class Category < ApplicationRecord
  acts_as_paranoid

  has_many :assets

  # Self-referential associations for parent/child relationships
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :subcategories, class_name: 'Category', foreign_key: 'parent_id'

  validates :name, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "description", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["assets"]
  end
end
