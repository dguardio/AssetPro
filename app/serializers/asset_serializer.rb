class AssetSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :asset_code, :status,
             :purchase_date, :purchase_price, :rfid_enabled,
             :last_tracked_at, :depreciation_rate, :quantity,
             :minimum_quantity, :useful_life_years, :salvage_value,
             :warranty_expiry_date, :maintenance_cost_yearly,
             :insurance_value, :created_at, :updated_at, :deleted_at

  belongs_to :category
  belongs_to :location
  has_one :rfid_tag
end 