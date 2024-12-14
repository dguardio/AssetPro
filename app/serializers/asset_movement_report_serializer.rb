class AssetMovementReportSerializer < ActiveModel::Serializer
  attributes :id,
             :event_type,
             :scanned_at,
             :created_at

  belongs_to :asset
  belongs_to :location
  belongs_to :scanned_by, class_name: 'User'

  def asset
    {
      id: object.asset.id,
      name: object.asset.name,
      asset_code: object.asset.asset_code
    }
  end

  def location
    {
      id: object.location.id,
      name: object.location.name
    }
  end
end 