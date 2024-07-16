# == Schema Information
#
# Table name: contacts
#
#  id           :bigint           not null, primary key
#  name         :string
#  email        :string
#  phone_number :string
#  user_id      :integer
#  deleted_at   :datetime
#  status       :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_contacts_on_user_id  (user_id)
#
FactoryBot.define do
  factory :contact do
    name { Faker::Name.firstname }
    sequence(:email) { |n| "#{n}_#{Faker::Internet.email}" }
    phone_number { Faker::PhoneNumber.cell_phone.gsub(/-/, '') }
  end
end
