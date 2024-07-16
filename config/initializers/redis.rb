module RedisInstance
  class << self
    def current
      @current ||= Redis.new(
        url: ENV.fetch('REDIS_URL') { 'redis://redis:6379/1' },
        driver: :ruby,
        ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
      )
    end
  end
end
