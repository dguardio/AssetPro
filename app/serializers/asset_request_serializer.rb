class AssetRequestSerializer < ActiveModel::Serializer
  attributes :id,
             :status,
             :purpose,
             :requested_from,
             :requested_until,
             :rejection_reason,
             :reviewed_at,
             :created_at,
             :updated_at

  belongs_to :asset
  belongs_to :user
  belongs_to :reviewed_by, class_name: 'User'
end 