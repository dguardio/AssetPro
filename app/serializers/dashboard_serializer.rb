class DashboardSerializer < ActiveModel::Serializer
  attributes :metrics, :assets_by_status, :assets_by_category, 
             :assets_by_location, :recent_activities

  def recent_activities
    ActiveModel::SerializableResource.new(
      object.recent_activities,
      each_serializer: AssetTrackingEventSerializer
    )
  end
end 