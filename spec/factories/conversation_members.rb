# frozen_string_literal: true

FactoryBot.define do
  factory :conversation_member do
    association :conversation
    association :user
    status { :active }
    is_admin { false }
  end
end
