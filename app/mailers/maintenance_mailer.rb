class MaintenanceMailer < ApplicationMailer
  def maintenance_completed
    @schedule = params[:maintenance_schedule]
    @completed_by = params[:completed_by]
    @recipient = params[:recipient]
    
    mail(
      to: @recipient.email,
      subject: "Maintenance Completed: #{@schedule.asset.name}"
    )
  end
end 