module DashboardsHelper
  def search_params
    params[:q]&.permit(
      :category_id_eq,
      :location_id_eq,
      :status_eq,
      :rfid_enabled_eq,
      :s
    )&.to_h || {}
  end
end 