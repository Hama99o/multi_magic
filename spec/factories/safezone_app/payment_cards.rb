# == Schema Information
#
# Table name: safezone_app_payment_cards
#
#  id          :bigint           not null, primary key
#  owner_id    :bigint
#  status      :integer          default("trashed"), not null
#  name        :string
#  card_type   :integer          default("credit_card"), not null
#  card_number :string
#  cvv         :string
#  expiry_date :string
#  deleted_at  :datetime
#  note        :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_safezone_app_payment_cards_on_owner_id  (owner_id)
#
FactoryBot.define do
  factory :safezone_app_payment_card, class: 'SafezoneApp::PaymentCard' do
    association :owner, factory: :user
    status { 0 }
    name { "Test Card" }
    card_type { 0 }
    card_number { "1234567890123456" }
    cvv { "123" }
    expiry_date { "2025-12-31" }
    note { {} }
  end
end
