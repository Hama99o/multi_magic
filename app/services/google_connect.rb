class GoogleConnect
  class << self
    def client(opt = {})
      @client ||= Signet::OAuth2::Client.new(client_options.merge(opt))
    end

    def client_options
      {
        client_id: Rails.application.credentials[:google_client_id],
        client_secret: Rails.application.credentials[:google_client_secret],
        authorization_uri: "https://accounts.google.com/o/oauth2/auth",
        token_credential_uri: "https://accounts.google.com/o/oauth2/token",
        scope: "email profile openid",
        redirect_uri: "#{ENV.fetch("VITE_API_URL", nil)}/google/callback"
      }
    end
  end
end
