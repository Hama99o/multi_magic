class ContactApp::ContactController < ApplicationController
  def index
    @contacts =  ContactApp::Contact.all
    render json: @contacts
  end

  def create
    @contact =  ContactApp::Contact.new(contact_params)
    if @contact.save
      render json: @contact, status: :created
    else
      render json: @contact.errors, status: :unprocessable_entity
    end
  end

  def export_vcard
    contact =  ContactApp::Contact.find(params[:id])
    send_data contact.to_vcard, filename: "#{contact.first_name}_#{contact.last_name}.vcf"
  end

  def import_vcard
    file = params[:file]
    vcard = VCardigan.parse(file.read)

    contact =  ContactApp::Contact.new(
      first_name: vcard.name.first,
      last_name: vcard.name.last,
      email: vcard.email.first,
      phone: vcard.tel.first,
      address: vcard.adr.first.join(", ")
    )

    if contact.save
      render json: contact, status: :created
    else
      render json: contact.errors, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:first_name, :last_name, :email, :phone, :address)
  end

end
