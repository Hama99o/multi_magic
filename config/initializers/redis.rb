$redis = Redis.new

url = ENV.fetch("REDIS_URL", nil)

if url

  # Sever conf
  Sidekiq.configure_server do |config|
    config.redis = { url: }

    # comes from https://github.com/paladinsoftware/sidekiq-debouncer
    config.client_middleware do |chain|
      chain.add Sidekiq::Debouncer::Middleware::Client
    end

    config.server_middleware do |chain|
      chain.add Sidekiq::Debouncer::Middleware::Server
    end
  end

  # Client conf
  Sidekiq.configure_client do |config|
    config.redis = { url: }

    config.client_middleware do |chain|
      chain.add Sidekiq::Debouncer::Middleware::Client
    end
  end

  $redis = Redis.new(url:)
end
