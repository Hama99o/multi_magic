# frozen_string_literal: true

FactoryBot.define do
  factory :blog_app_tag, class: 'BlogApp::Tag' do
    sequence(:name) { |n| "#{Faker::Lorem.word}#{n}" }
    association :user
  end
end
