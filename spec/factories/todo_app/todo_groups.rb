# frozen_string_literal: true

FactoryBot.define do
  factory :todo_group, class: 'TodoApp::TodoGroup' do
    sequence(:name) { |n| "Group #{n}" }
    association :user
  end
end
