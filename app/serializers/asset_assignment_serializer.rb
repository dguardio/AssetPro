class AssetAssignmentSerializer < ActiveModel::Serializer
  attributes :id,
             :checked_out_at,
             :checked_in_at,
             :expected_return_date,
             :notes,
             :created_at,
             :updated_at

  belongs_to :asset
  belongs_to :user
  belongs_to :assigned_by, class_name: 'User'
end 