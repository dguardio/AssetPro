module AssetParameters
  extend ActiveSupport::Concern

  included do
    helper_method :ransack_params
  end

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

  def ransack_params
    params.fetch(:q, {}).permit(
      :name_cont, 
      :asset_code_cont,
      :category_id_eq,
      :location_id_eq,
      :status_eq,
      :description_cont,
      :rfid_enabled_eq
    )
  end
end 