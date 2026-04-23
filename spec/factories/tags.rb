# frozen_string_literal: true

# == Schema Information
#
# Table name: tags
#
#  id          :integer          not null, primary key
#  name        :string
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer
#  parent_id   :integer
#  position    :integer
#  description :string
#
# Indexes
#
#  index_tags_on_user_id  (user_id)
#

FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| Faker::Lorem.word + n.to_s }
    description { Faker::Lorem.paragraph }
  end
end
