module AssetParameters
  extend ActiveSupport::Concern

  private

  def asset_params
    params.require(:asset).permit(
      :name,
      :description,
      :asset_code,
      :status,
      :purchase_date,
      :purchase_price,
      :category_id,
      :location_id,
      :rfid_enabled,
      :last_tracked_at,
      :depreciation_rate,
      :quantity,
      :minimum_quantity,
      :useful_life_years,
      :salvage_value,
      :warranty_expiry_date,
      :maintenance_cost_yearly,
      :insurance_value
    )
  end
end 