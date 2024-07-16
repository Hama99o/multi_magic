class UserMailer < ApplicationMailer

  def welcome_email(user)
    @user = user
    # @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to Multi Magic')
  end


  def reset_password(user)
    @user = user
    @token = @user.reset_password_token
    @button_link = email_redirect_to_front("/reset_password?reset_password_token=#{@token}")

    mail(to: @user.email, subject: "Reset your password")
  end
end
