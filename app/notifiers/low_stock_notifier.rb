class LowStockNotifier < ApplicationNotifier
  deliver_by :email do |config|
    config.mailer = "AssetMailer"
    config.method = :low_stock_email
  end

  required_param :asset
  required_param :notification_type

  def message
    case params[:notification_type]
    when :minimum_reached
      "Asset #{params[:asset].name} has reached minimum stock level (#{params[:asset].available_quantity} available)"
    when :out_of_stock
      "Asset #{params[:asset].name} is out of stock"
    end
  end

  def url
    Rails.application.routes.url_helpers.asset_path(params[:asset])
  end

  def self.minimum_reached(asset)
    with(
      asset: asset,
      notification_type: :minimum_reached
    ).deliver_later(User.with_role(:manager))
  end

  def self.out_of_stock(asset)
    with(
      asset: asset,
      notification_type: :out_of_stock
    ).deliver_later(User.with_role(:manager))
  end

  # Add your delivery methods
  #
  # deliver_by :email do |config|
  #   config.mailer = "UserMailer"
  #   config.method = "new_post"
  # end
  #
  # bulk_deliver_by :slack do |config|
  #   config.url = -> { Rails.application.credentials.slack_webhook_url }
  # end
  #
  # deliver_by :custom do |config|
  #   config.class = "MyDeliveryMethod"
  # end
end
