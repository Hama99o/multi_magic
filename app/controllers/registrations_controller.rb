# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted?
        # add applications
        resource.update(applications: ['NoteApp', 'MyFinanceApp', 'ContactApp', 'BlogApp'])
        # Call mailer to send welcome email
        resource.new_user_stuff!
      end
    end
  end

  private

  def respond_with(resource, _opts = {})
    render(json: UserSerializer.render_as_hash(resource, view: :private)) && return if resource.persisted?

    render json: { messages: resource.errors.full_messages }
  end

  def sign_up_params
    params.require(:user).permit(:firstname, :lastname, :birth_date, :email, :password, :agreed_to_terms)
  end
end
