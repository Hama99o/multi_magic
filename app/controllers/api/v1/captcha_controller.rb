class Api::V1::CaptchaController < ApplicationController
  def generate
    # Generate a random string, e.g., 6 alphanumeric characters
    captcha_text = SecureRandom.alphanumeric(6)

    # Store it in the session for validation
    session[:captcha] = captcha_text

    # Respond with the CAPTCHA text as JSON (for Vue to display)
    render json: { captcha: captcha_text }
  end

  def validate
    # Compare the CAPTCHA the user entered with the one in the session
    if params[:captcha].downcase == session[:captcha].downcase
      render json: { success: true }
    else
      render json: { success: false, error: "Captcha doesn't match." }
    end
  end
end
