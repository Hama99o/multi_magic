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

require 'rails_helper'

RSpec.describe Address, type: :model do
  subject(:address) { build(:address, addressable: contact) }

  let(:user) { create(:user) }
  let(:contact) { create(:contact_app_contact, user: user) }

  describe 'associations' do
    it { is_expected.to belong_to(:addressable) }
  end

  describe 'creation' do
    it 'is valid with an addressable' do
      expect(address).to be_valid
    end

    it 'stores city and country' do
      address.city = 'Paris'
      address.country = 'France'
      address.save!
      expect(address.reload.city).to eq('Paris')
      expect(address.reload.country).to eq('France')
    end
  end
end
