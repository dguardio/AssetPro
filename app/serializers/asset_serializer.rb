class AssetSerializer < ActiveModel::Serializer
  attributes :id, :name, :asset_code, :status, :description
  
  belongs_to :location
  belongs_to :rfid_tag
end 