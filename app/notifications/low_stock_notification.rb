class LowStockNotification < ApplicationNotification
  param :asset

  def url
    asset_path(params[:asset])
  end

  def message
    asset = params[:asset]
    "Asset #{asset.name} is running low on stock (Current: #{asset.quantity})"
  end
end 