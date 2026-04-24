# == Schema Information
#
# Table name: addresses
#
#  id               :integer          not null, primary key
#  addressable_type :string
#  addressable_id   :integer
#  city             :string
#  country          :string
#  postal_code      :integer
#  state            :string
#  is_default       :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_addresses_on_addressable  (addressable_type,addressable_id)
#

# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    city { Faker::Address.city }
    country { Faker::Address.country }
    postal_code { Faker::Address.zip_code.to_i }
    state { Faker::Address.state }
    is_default { false }
    addressable { nil }
  end
end
