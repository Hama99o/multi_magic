# == Schema Information
#
# Table name: safezone_app_identities
#
#  id              :bigint           not null, primary key
#  user_id         :bigint           not null
#  type            :string           not null
#  document_number :string           not null
#  issued_at       :date
#  expires_at      :date
#  image           :string
#  data            :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_safezone_app_identities_on_user_id  (user_id)
#
FactoryBot.define do
  factory :identity, class: 'SafezoneApp::Identity' do
    association :user
    type { "SafezoneApp::Identities::Passport" }
    document_number { "P123456789" }
    issued_at { Date.new(2020, 5, 10) }
    expires_at { Date.new(2030, 5, 10) }
    image { "uploads/passports/p123456789.jpg" }
    data { { country: "USA", holder_name: "John Doe" } }
  end

  factory :driving_license, class: 'SafezoneApp::Identities::DrivingLicense' do
    association :user
    type { "SafezoneApp::Identities::DrivingLicense" }
    document_number { "DL-987654321" }
    issued_at { Date.new(2021, 8, 15) }
    expires_at { Date.new(2026, 8, 15) }
    image { "uploads/licenses/dl-987654321.jpg" }
    data { { state: "California", category: "B" } }
  end

  factory :id_card, class: 'SafezoneApp::Identities::IdCard' do
    association :user
    type { "SafezoneApp::Identities::IdCard" }
    document_number { "ID-123456789" }
    issued_at { Date.new(2019, 1, 1) }
    expires_at { Date.new(2029, 1, 1) }
    image { "uploads/id_cards/id-123456789.jpg" }
    data { { country: "USA", holder_name: "Jane Doe" } }
  end
end
