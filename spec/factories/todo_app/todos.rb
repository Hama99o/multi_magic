# frozen_string_literal: true

FactoryBot.define do
  factory :todo, class: 'TodoApp::Todo' do
    sequence(:title) { |n| "Todo #{n}" }
    notes { Faker::Lorem.sentence }
    completed { false }
    association :todo_group, factory: :todo_group
    association :user
  end
end
