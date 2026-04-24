# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted?
        # add applications
        resource.update(applications: %w[NoteApp MyFinanceApp ContactApp BlogApp SafezoneApp])
        # Call mailer to send welcome email
        resource.new_user_stuff!
      end
    end
  end

  private

  def respond_with(resource, _opts = {})
    return render(json: UserSerializer.render_as_hash(resource, view: :private)) if resource.persisted?

    errors = resource.errors.map do |error|
      {
        code: error.type.to_s,
        source: { pointer: "/data/attributes/#{error.attribute}" },
        detail: error.message
      }
    end
    render json: { errors: }, status: :bad_request
  end

  def sign_up_params
    params.expect(user: %i[firstname lastname birth_date email password password_confirmation agreed_to_terms])
  end
end
