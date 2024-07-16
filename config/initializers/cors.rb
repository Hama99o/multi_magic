# frozen_string_literal
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # origins { |source, env| true }
    # origins ENV["FRONT_DOMAIN"]
    origins "*"
    resource "*",
             headers: :any,
             expose: "*",
             methods: %i[get post put patch delete options]
             # credentials: true
  end
end
