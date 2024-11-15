class AssetAssignmentMailer < ApplicationMailer
  def notification_email
    @notification = params[:notification]
    @recipient = params[:recipient]
    @assignment = @notification.params[:asset_assignment]
    
    mail(
      to: @recipient.email,
      subject: "New Asset Assignment: #{@assignment.asset.name}"
    )
  end
end 