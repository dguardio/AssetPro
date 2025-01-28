class ApplicationNotifier < Noticed::Event
  deliver_by :action_cable do |config|
    config.channel = "NotificationChannel"
    config.stream = :notification_stream
    config.message = :to_action_cable
  end

  def notification_stream
    "notifications_#{recipient.id}"
  end

  def to_action_cable
    {
      type: self.class.name.underscore.gsub('_notifier', ''),
      message: message,
      url: url,
      title: self.class.name.titleize.gsub('Notifier', '')
    }
  end

  def url
    raise NotImplementedError, "Subclass must implement #url"
  end

  def message
    raise NotImplementedError, "Subclass must implement #message"
  end
end
