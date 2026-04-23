# == Schema Information
#
# Table name: views
#
#  id            :integer          not null, primary key
#  viewable_type :string           not null
#  viewable_id   :integer          not null
#  user_id       :integer
#  ip_address    :string
#  user_agent    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_views_on_user_id                (user_id)
#  index_views_on_viewable               (viewable_type,viewable_id)
#  index_views_on_viewable_and_ip_agent  (viewable_type,viewable_id,ip_address,user_agent) UNIQUE
#  index_views_on_viewable_and_user      (viewable_type,viewable_id,user_id) UNIQUE
#

# frozen_string_literal: true

FactoryBot.define do
  factory :view do
    association :user
    ip_address { Faker::Internet.ip_v4_address }
    user_agent { Faker::Internet.user_agent }
    viewable { nil }

    trait :for_article do
      association :viewable, factory: :blog_app_article
    end
  end
end
