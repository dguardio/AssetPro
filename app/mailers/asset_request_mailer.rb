class AssetRequestMailer < ApplicationMailer
  def notification_email
    @notification = params[:notification]
    @recipient = params[:recipient]
    @asset_request = @notification.params[:asset_request]
    
    mail(
      to: @recipient.email,
      subject: "Asset Request Update: #{@asset_request.asset.name}"
    )
  end
end 