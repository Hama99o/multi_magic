# == Schema Information
#
# Table name: images
#
#  id             :integer          not null, primary key
#  file           :string
#  imageable_type :string           not null
#  imageable_id   :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_images_on_imageable  (imageable_type,imageable_id)
#

# frozen_string_literal: true

FactoryBot.define do
  factory :image do
    imageable { nil }
  end
end
