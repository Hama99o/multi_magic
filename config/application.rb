require_relative 'boot'

require 'rails/all'
require 'sidekiq/web'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MultiMagic
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

    # Log to STDOUT. You could then collect logs using journald, syslog or forward them somewhere else.
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)

    # Set Redis as the back-end for the cache.
    config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_URL", nil) }

    # Set Sidekiq as the back-end for Active Job.
    config.active_job.queue_adapter = :sidekiq

    # Mount Action Cable outside the main process or domain.
    config.action_cable.mount_path = nil
    config.action_cable.url = ENV.fetch('ACTION_CABLE_FRONTEND_URL') { 'ws://localhost:28081' }
    config.action_cable.disable_request_forgery_protection = true

    # Only allow connections to Action Cable from these domains.
    origins = ENV.fetch('ACTION_CABLE_ALLOWED_REQUEST_ORIGINS') { "http:\/\/localhost*" }.split(',')
    origins.map! { |url| /#{url}/ }
    config.action_cable.allowed_request_origins = origins

    # Protect sidekiq-web
    Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(username, ENV.fetch('SIDEKIQ_WEB_USERNAME', 'sidekiq-web-dashboard')) &&
        ActiveSupport::SecurityUtils.secure_compare(password, ENV.fetch('SIDEKIQ_WEB_PASSWORD', 'sidekiq-web-123'))
    end

    host = ENV['DEFAULT_HOST']

    config.action_mailer.default_url_options = { host: }

    Rails.application.routes.default_url_options[:host] = host
    # config.action_mailer.delivery_method = :postmark
    # config.action_mailer.postmark_settings = { api_token: Rails.application.credentials[:postmark_api_token] }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: Rails.application.credentials[:smtp_address],
      port: Rails.application.credentials[:smtp_port],
      domain: Rails.application.credentials[:smtp_domain],
      user_name: Rails.application.credentials[:smtp_username],
      password: Rails.application.credentials[:smtp_password],
      authentication: :plain,
      enable_starttls_auto: true
    }
  end
end
