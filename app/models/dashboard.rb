class Dashboard
  include ActiveModel::Model
  include ActiveModel::Serialization
  
  attr_accessor :total_assets, :assets_in_use, :assets_available, 
                :active_assignments, :recent_movements

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
end 