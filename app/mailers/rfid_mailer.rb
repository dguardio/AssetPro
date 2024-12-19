class RfidMailer < ApplicationMailer
  def unauthorized_scan_attempt
    @scan = params[:scan]
    @location = params[:location]
    @recipient = params[:recipient]
    
    mail(
      to: @recipient.email,
      subject: "Security Alert: Unauthorized RFID Scan Attempt"
    )
  end

  def reader_offline
    @reader = params[:reader]
    @recipient = params[:recipient]
    
    mail(
      to: @recipient.email,
      subject: "Alert: RFID Reader Offline"
    )
  end

  def tag_deactivated
    @asset = params[:asset]
    @recipient = params[:recipient]
    
    mail(
      to: @recipient.email,
      subject: "RFID Tag Deactivated: #{@asset.name}"
    )
  end
end 