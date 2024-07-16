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
class ContactApp::ContactSerializer < ApplicationSerializer
  identifier :id
  fields :email, :birth_date, :user_id, :address, :phone, :firstname, :lastname

  field :fullname do |user|
    user.fullname.presence
  end
end
