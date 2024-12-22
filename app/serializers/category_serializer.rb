class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :created_at, :updated_at, :deleted_at
  
  belongs_to :parent, serializer: CategorySerializer
  has_many :children, serializer: CategorySerializer
end 