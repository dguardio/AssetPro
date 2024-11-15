class ApplicationNotification < Noticed::Base
  # Delivery methods
  deliver_by :database

  # I18n helper
  def self.t(key, **options)
    I18n.t("notifications.#{self.name.underscore.tr('/', '.')}.#{key}", **options)
  end

  def message
    self.class.t("message", **params)
  end

  def url
    raise NotImplementedError, "Subclass must implement #url"
  end
end 