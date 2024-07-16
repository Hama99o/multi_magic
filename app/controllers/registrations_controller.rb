# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      if resource.persisted?
        # add applications
        resource.update(applications: ['NoteApp', 'MyFinanceApp', 'ContactApp', 'BlogApp'])
        # Call mailer to send welcome email
        UserMailer.welcome_email(resource).deliver_now
        email_records = EmailRecord.where(email: resource.email)

        email_records.each do |email_record|
          role = email_record.additional_info['role'] || 'viewer'
          note = email_record.shareable

          if email_record.shareable_type ==  "NoteApp::Note"
            NoteApp::Share.create(shared_with_user: resource, note:, role:)
            email_record.destroy
          end

        end
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
