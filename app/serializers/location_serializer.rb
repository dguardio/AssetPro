class LocationSerializer < ActiveModel::Serializer
  attributes :id,
             :name,
             :address,
             :building,
             :floor,
             :room,
             :created_at,
             :updated_at,
             :asset_count

  has_many :assets
  has_many :asset_tracking_events

  def asset_count
    object.assets.size
  end
end 