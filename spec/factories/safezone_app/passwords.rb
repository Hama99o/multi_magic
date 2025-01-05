# == Schema Information
#
# Table name: safezone_app_passwords
#
#  id         :bigint           not null, primary key
#  owner_id   :bigint
#  status     :integer          default("trashed"), not null
#  data       :jsonb
#  title      :string
#  email      :string
#  link       :string
#  username   :string
#  note       :jsonb
#  deleted_at :datetime
#  password   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_safezone_app_passwords_on_owner_id  (owner_id)
#
FactoryBot.define do
  factory :safezone_app_passwords, class: 'SafezoneApp::Password' do
    association :owner, factory: :user
    status { 0 }
    title { "Test Password" }
    email { "test@example.com" }
    link { "https://example.com" }
    username { "testuser" }
    password { "password123" }
    note { {} }
    data { {} }
  end
end
