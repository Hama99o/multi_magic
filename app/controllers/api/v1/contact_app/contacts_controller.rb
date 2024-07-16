class Api::V1::ContactApp::ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :update, :destroy, :destroy_permanently, :restore, :export_vcard]

  def index
    contacts = policy_scope(current_user.contacts.where(status: :published))
    contact_index(contacts)
  end

  # GET /contacts/trashes
  def trashes
    contacts = policy_scope(current_user.contacts.where(status: :trashed))
    contact_index(contacts)
  end

  # GET /contacts/:id
  def show
    render json: { contact: ContactApp::ContactSerializer.render_as_json(@contact)}
  end

  # PUT /contacts/:id
  def update
    if authorize(@contact).update(contact_params)
      render json: { contact: ContactApp::ContactSerializer.render_as_json(@contact)}
    else
      render json: @contact.errors, status: :unprocessable_entity
    end
  end

  def create
    @contact = authorize(ContactApp::Contact).new(contact_params.merge(status: :published, user: current_user))

    if @contact.save
      render json: { contect: ContactApp::ContactSerializer.render_as_json(@contact) }, status: :created
    else
      render json: @contact.errors, status: :unprocessable_entity
    end
  end

  def export_vcard
    contact = authorize(@contact)
    send_data contact.to_vcard, filename: "#{contact.firstname}_#{contact.lastname}.vcf"
  end

  def export_multiple_contacts
    ids = params[:ids]
    contacts = ContactApp::Contact.where(id: ids)

    vcards = contacts.map do |contact|
      contact.to_vcard
    end

    combined_vcards = vcards.join("\n")

    send_data combined_vcards, filename: "contacts.vcf", type: 'text/vcard'
  end

  def import_vcard
    file = params[:file]
    vcard = VCardigan.parse(file.read)

    contact = authorize(ContactApp::Contact).new(
      firstname: vcard.name.first,
      lastname: vcard.name.last,
      email: vcard.email.first,
      phone: vcard.tel.first,
      # address: vcard.adr.first.join(", ")
      status: :published,
      user: current_user
    )

    if contact.save
      render json: { contect: ContactApp::ContactSerializer.render_as_json(contact) }, status: :created
    else
      render json: contact.errors, status: :unprocessable_entity
    end
  end

  # DELETE /contacts/:id
  def destroy
    if authorize(@contact).update(status: :trashed, deleted_at: Time.now)
      render json: @contact
    else
      render_unprocessable_entity(@contact)
    end
  end

  def destroy_permanently
    if authorize(@contact).delete
      render json: { contact: @contact }, status: :ok
    else
      render_unprocessable_entity(@contact)
    end
  end

  def restore
    if authorize(@contact).update(status: :published, deleted_at: nil)
      render json: @contact
    else
      render_unprocessable_entity(@contact)
    end
  end

  private

  # Find contact by ID
  def set_contact
    @contact = ContactApp::Contact.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Contact not found' }, status: :not_found
  end

  def contact_index(contacts)
    contacts = contacts.search_contacts(params[:search]) if params[:search].present?

    paginate_render(
      ContactApp::ContactSerializer,
      # policy_scope(contacts.order(updated_at: :desc)),
      contacts.order(updated_at: :desc),
      per_page: 5,
      extra: {
        root: :contacts,
        current_user: current_user
      }
    )
  end

  def contact_params
    params.require(:contact).permit(:firstname, :lastname, :email, :phone, :address, :birth_date)
  end
end
