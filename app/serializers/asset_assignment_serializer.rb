class AssetAssignmentSerializer < ActiveModel::Serializer
  attributes :id,
             :asset_id,
             :user_id,
             :assigned_by_id,
             :checked_out_at,
             :checked_in_at,
             :notes,
             :created_at,
             :updated_at

  belongs_to :asset
  belongs_to :user
  belongs_to :assigned_by, class_name: 'User'
end 