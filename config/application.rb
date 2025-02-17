require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AssetPro
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.assets.initialize_on_precompile = false

    config.action_mailer.delivery_method = :postmark

    config.action_mailer.postmark_settings = { :api_token => ENV['postmark_api_token'] } 
 

    # Add this line to ensure concerns are autoloaded
    config.autoload_paths += %W(#{config.root}/app/models/concerns)
    config.eager_load_paths += %W(#{config.root}/app/models/concerns)

    # config.active_job.queue_adapter = :sidekiq
    config.active_job.queue_adapter = :async  # Change from :sidekiq to :async

    # config.middleware.insert_before 0, Rack::Cors do
    #   allow do
    #     origins '*' # Use specific domains in production
    #     resource '*',
    #       headers: :any,
    #       methods: [:get, :post, :put, :patch, :delete, :options, :head],
    #       expose: ['Authorization']
    #   end
    # end

  end
end
