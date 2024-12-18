class AssetStatusNotification < ApplicationNotification
  param :asset
  param :status
  param :changed_by

  def message
    "Asset #{params[:asset].name} status changed to #{params[:status]} by #{params[:changed_by].name}"
  end

  def url
    asset_path(params[:asset])
  end
end 