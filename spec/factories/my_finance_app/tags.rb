# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id          :bigint           not null, primary key
#  name        :string
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint
#  parent_id   :bigint
#  position    :integer
#  description :string
#
# Indexes
#
#  index_tags_on_user_id  (user_id)
#
FactoryBot.define do
  factory :my_finance_app_tag, class: 'MyFinanceApp::Tag' do
    sequence(:name) { |n| Faker::Lorem.word + n.to_s }
  end
end
