class DashboardSerializer < ActiveModel::Serializer
  attributes :total_assets,
             :assets_in_use,
             :assets_available,
             :active_assignments

  has_many :recent_movements, serializer: AssetTrackingEventSerializer
end 