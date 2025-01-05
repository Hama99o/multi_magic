FactoryBot.define do
  factory :payment_card, class: 'SafezoneApp::PaymentCard' do
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
