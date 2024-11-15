# To deliver this notification:
#
# AssetAssignmentNotifier.with(record: @post, message: "New post").deliver(User.all)

class AssetAssignmentNotifier < Noticed::Event
  deliver_by :database
  deliver_by :email do |config|
    config.mailer = "AssetAssignmentMailer"
    config.method = :notification_email
  end

  required_params :asset_assignment

  notification_methods do
    def message
      t(".message", 
        asset: params[:asset_assignment].asset.name,
        assigned_by: params[:asset_assignment].assigned_by.full_name)
    end

    def url
      asset_path(params[:asset_assignment].asset)
    end
  end
end
