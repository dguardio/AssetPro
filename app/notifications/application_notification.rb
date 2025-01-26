class ApplicationNotification < Noticed::Event
  # Common delivery methods for all notifications
  # deliver_by :database
  deliver_by :action_cable,
    channel: "NotificationChannel",
    stream: :custom_stream,
    message: :notification_message

  # I18n helper
  def self.t(key, **options)
    I18n.t("notifications.#{self.name.underscore.tr('/', '.')}.#{key}", **options)
  end

  def notification_stream
    "notifications_#{recipient.id}"
  end

  def to_action_cable
    {
      notification_type: notification_type,
      message: message,
      url: url,
      title: self.class.name.titleize.gsub('Notification', '')
    }
  end

  def notification_type
    self.class.name.underscore.gsub('_notification', '')
  end

  def message
    self.class.t("message", **params)
  end

  def url
    raise NotImplementedError, "Subclass must implement #url"
  end
end 