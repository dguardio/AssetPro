# To deliver this notification:
#
# MaintenanceDueNotifier.with(record: @post, message: "New post").deliver(User.all)

class MaintenanceDueNotifier < ApplicationNotifier
  deliver_by :email do |config|
    config.mailer = "MaintenanceMailer"
    config.method = :maintenance_due_email
  end

  required_param :maintenance_schedule
  required_param :notification_type

  def message
    case params[:notification_type]
    when :maintenance_due
      "Maintenance due for #{params[:maintenance_schedule].asset.name}"
    when :maintenance_completed
      "Maintenance completed for #{params[:maintenance_schedule].asset.name}"
    end
  end

  def url
    Rails.application.routes.url_helpers.maintenance_schedule_path(params[:maintenance_schedule])
  end

  def self.maintenance_due(maintenance_schedule)
    recipients = [
      maintenance_schedule.asset.current_assignment.user,
      maintenance_schedule.assigned_to
    ].compact + User.with_role(:manager)

    with(
      maintenance_schedule: maintenance_schedule,
      notification_type: :maintenance_due
    ).deliver_later(recipients)
  end

  def self.maintenance_completed(maintenance_schedule)
    recipients = []
    
    # Add current asset assignment user if exists
    if maintenance_schedule.asset&.current_assignment&.user
      recipients << maintenance_schedule.asset.current_assignment.user
    end
    
    # Add assigned maintenance user if exists
    recipients << maintenance_schedule.assigned_to if maintenance_schedule.assigned_to
    
    # Add all managers
    recipients += User.with_role(:manager)
    
    # Remove duplicates and nil values
    recipients = recipients.compact.uniq
    
    with(
      maintenance_schedule: maintenance_schedule,
      notification_type: :maintenance_completed
    ).deliver_later(recipients)
  end

  # Add your delivery methods
  #
  # bulk_deliver_by :slack do |config|
  #   config.url = -> { Rails.application.credentials.slack_webhook_url }
  # end
  #
  # deliver_by :custom do |config|
  #   config.class = "MyDeliveryMethod"
  # end
end
