require 'openssl'
require 'redis'

url = ENV.fetch("REDIS_URL", nil)

if url
  ssl_params = { verify_mode: OpenSSL::SSL::VERIFY_NONE } # Only for development or testing

  # Server configuration
  Sidekiq.configure_server do |config|
    config.redis = { url: url, ssl_params: ssl_params }

    config.client_middleware do |chain|
      chain.add Sidekiq::Debouncer::Middleware::Client
    end

    config.server_middleware do |chain|
      chain.add Sidekiq::Debouncer::Middleware::Server
    end
  end

  # Client configuration
  Sidekiq.configure_client do |config|
    config.redis = { url: url, ssl_params: ssl_params }

    config.client_middleware do |chain|
      chain.add Sidekiq::Debouncer::Middleware::Client
    end
  end

  # Redis instance
  $redis = Redis.new(url: url, ssl_params: ssl_params)
end
