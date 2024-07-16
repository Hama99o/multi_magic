require 'jwt'

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Expect `token` and `email` to be passed as connection parameters
      token = request.params[:token]
      email = request.params[:email]
      # Validate email and token (using your own token verification logic)

      if email && token
        user = User.find_by(email: email)

        if user && valid_token?(user, token)  # Replace `valid_token?` with your JWT or token verification logic
          user  # Returns the verified user
        else
          reject_unauthorized_connection  # Reject the connection if the token is invalid
        end
      else
        reject_unauthorized_connection  # Reject if the parameters are missing
      end
    end

    def valid_token?(user, token)
      # Use your Rails secret key base to decode the token
      secret_key = Rails.application.secrets.secret_key_base

      begin
        # Decode the token. This will also verify the signature.
        decode_user = Warden::JWTAuth::UserDecoder.new.call(token.split(' ').last, :user, nil)
        # Extract the payload (first element of decoded_token array)
        decode_user.id == user.id && decode_user.email == user.email
      rescue JWT::DecodeError => e
        # Handle invalid token or decoding errors
        Rails.logger.error "JWT Decode Error: #{e.message}"
        false
      end
    end
  end
end
