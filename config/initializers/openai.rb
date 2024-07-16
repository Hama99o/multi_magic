# config/initializers/openai.rb

# require 'ruby-openai'

OpenAI.configure do |config|
  config.access_token = Rails.application.credentials.dig(:openai_api_key)
end