class AssetMailer < ApplicationMailer
  def low_stock_email
    @notification = params[:notification]
    @recipient = params[:recipient]
    @asset = @notification.params[:asset]
    
    mail(
      to: @recipient.email,
      subject: "Low Stock Alert: #{@asset.name}"
    )
  end
end 