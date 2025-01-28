class AssetAssignmentMailer < ApplicationMailer
  def notification_email
    @notification = params[:notification]
    @recipient = params[:recipient]
    @asset_assignment = @notification.params[:asset_assignment]
    
    subject = case @notification.params[:notification_type]
    when :created
      "New Asset Assignment: #{@asset_assignment.asset.name}"
    when :checked_out
      "Asset Checked Out: #{@asset_assignment.asset.name}"
    when :checked_in
      "Asset Checked In: #{@asset_assignment.asset.name}"
    end
    
    mail(
      to: @recipient.email,
      subject: subject
    )
  end
end 