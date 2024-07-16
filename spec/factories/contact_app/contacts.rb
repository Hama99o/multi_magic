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
FactoryBot.define do
  factory :contact_app_contact, class: 'ContactApp::Contact' do
    firstname { "MyString" }
    lastname { "MyString" }
    email { "MyString" }
    phone { "MyString" }
    address { "MyString" }
  end
end
