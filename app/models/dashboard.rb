class Dashboard
  include ActiveModel::Model
  include ActiveModel::Serialization
  include ActiveModel::Serializers::JSON
  
  attr_accessor :metrics, :assets_by_status, :assets_by_category, 
                :assets_by_location, :recent_activities

  def initialize(attributes = {})
    @metrics = attributes[:metrics]
    @assets_by_status = attributes[:assets_by_status]
    @assets_by_category = attributes[:assets_by_category]
    @assets_by_location = attributes[:assets_by_location]
    @recent_activities = attributes[:recent_activities]
  end

  # Required by ActiveModel::Serializers
  def read_attribute_for_serialization(attr)
    send(attr)
  end

  # Required by ActiveModel::Model
  def self.model_name
    ActiveModel::Name.new(self)
  end
end 