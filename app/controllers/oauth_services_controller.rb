require 'devise/jwt/test_helpers'

class OauthServicesController < ApplicationController
  # Skip authentication since this action is part of the login flow
  skip_before_action :authenticate_user!

  # Handle Google OAuth callback
  def google_connect
    begin
      # Initialize Google OAuth2 client
      client = GoogleConnect.client
      # Set the authorization code received from Google
      client.code = params.require(:code)
      # Exchange authorization code for access token
      client.fetch_access_token!

      # Fetch user info using the access token
      user_info = fetch_google_user_info(client.access_token)

      # If user info is retrieved successfully
      if user_info.present?
        # Find or initialize user by email
        user = User.find_or_initialize_by(email: user_info[:email])

        if user.persisted?
          sign_in_user(user)
        else
          # New user: Create and log them in
          user = create_new_user(user_info)
          if user.persisted?
            sign_in_user(user)
          else
            # Handle validation errors (e.g., missing required fields)
            redirect_to "#{ENV['VITE_API_URL']}/signup?errors=#{ERB::Util.url_encode(JSON.generate(user.errors.full_messages))}"
          end
        end
      else
        # If Google user info is invalid or missing
        redirect_to "#{ENV['VITE_API_URL']}/login?google_payload=true"
      end
    rescue => e
      # Log error for debugging purposes
      Rails.logger.error("Google OAuth Error: #{e.message}")
      # Redirect back to login in case of any error
      redirect_to "#{ENV['VITE_API_URL']}/login"
    end
  end

  private

  # Fetch Google user information using the access token
  def fetch_google_user_info(access_token)
    # Make a GET request to Google's userinfo endpoint
    response = Faraday.get(
      'https://www.googleapis.com/oauth2/v2/userinfo',
      {}, # No params required
      { Authorization: "Bearer #{access_token}" } # Include the access token in the headers
    )

    # Parse the JSON response body into Ruby hash and symbolize keys
    JSON.parse(response.body).symbolize_keys
  end

  # Create a new user from Google info
  def create_new_user(user_info)
    user = User.create(
      email: user_info[:email],
      firstname: user_info[:given_name] || 'Unknown',
      lastname: user_info[:family_name] || '',
      password: SecureRandom.hex(16), # Generate a secure random password
      status: 'active',
      join_date: Date.today,
      applications: ['NoteApp', 'MyFinanceApp', 'ContactApp', 'BlogApp']
    )

    user.new_user_stuff!


    # Attach profile photo if provided
    if user_info[:picture].present?
      downloaded_image = URI.parse(user_info[:picture]).open
      user.photo.attach(io: downloaded_image, filename: "google-profile-photo-#{user.email}.jpg")
    end

    user
  end

  def sign_in_user(user)
    # Sign in the user and generate JWT credentials
    sign_in(:user, user, store: false, bypass: false)
    creds = Devise::JWT::TestHelpers.auth_headers({}, user)

    # Redirect back to the frontend with user credentials
    redirect_to "#{ENV['VITE_API_URL']}/login?creds=#{creds['Authorization']}&user=#{ERB::Util.url_encode(JSON.generate(UserSerializer.render_as_hash(user)))}"
  end
end
