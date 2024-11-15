class AssetAssignmentNotification < ApplicationNotification
  param :asset_assignment

  def url
    asset_path(params[:asset_assignment].asset)
  end

  def message
    "Asset #{params[:asset_assignment].asset.name} has been assigned to you"
  end
end 