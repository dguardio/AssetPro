class AssetMailer < ApplicationMailer
  def notification_email
    @notification = params[:notification]
    @recipient = params[:recipient]
    @asset = @notification.params[:asset]
    
    subject = case @notification.params[:notification_type]
    when :status_changed
      "Asset Status Changed: #{@asset.name}"
    when :maintenance_due
      "Maintenance Due: #{@asset.name}"
    when :location_changed
      "Location Changed: #{@asset.name}"
    when :assignment_created
      "New Asset Assignment: #{@asset.name}"
    when :assignment_removed
      "Asset Assignment Removed: #{@asset.name}"
    end
    
    mail(
      to: @recipient.email,
      subject: subject
    )
  end

  def low_stock_email
    @notification = params[:notification]
    @recipient = params[:recipient]
    @asset = @notification.params[:asset]
    @notification_type = @notification.params[:notification_type]

    subject = case @notification_type
    when :minimum_reached
      "Low Stock Alert: #{@asset.name}"
    when :out_of_stock
      "Out of Stock Alert: #{@asset.name}"
    end

    mail(
      to: @recipient.email,
      subject: subject
    )
  end
end 