# == Schema Information
#
# Table name: contact_app_contacts
#
#  id         :bigint           not null, primary key
#  user_id    :integer
#  firstname  :string
#  lastname   :string
#  email      :string
#  phone      :string
#  address    :string
#  birth_date :date
#  status     :integer          default("trashed"), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ContactApp::Contact < ApplicationRecord
  belongs_to :user, class_name: "User"

  enum status: {
    trashed: 0,
    published: 1
  }

  include PgSearch::Model
  pg_search_scope :search_contacts,
                  against: [:lastname, :lastname, :email, :address],
                  using: {
                    tsearch: { prefix: true }
                  }
  def to_vcard
    vcard = VCardigan.create
    full_name = "#{self.firstname} #{self.lastname}"
    vcard.fn(full_name)   # Adding the FN (Formatted Name) field
    vcard.name("#{self.lastname};#{self.firstname}")
    vcard.email(self.email)
    vcard.tel(self.phone)
    vcard.bday('1990-01-01') # Adding the birthday
    vcard.adr(self.address)
    vcard.to_s
  end


  def fullname
    "#{firstname&.titleize} #{lastname&.upcase}"
  end
end
