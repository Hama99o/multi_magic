# frozen_string_literal: true

# == Schema Information
#
# Table name: contact_app_contacts
#
#  id         :bigint           not null, primary key
#  user_id    :integer
#  firstname  :string
#  lastname   :string
#  email      :string
#  phone      :string
#  address    :string
#  birth_date :date
#  status     :integer          default("trashed"), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe ContactApp::Contact, type: :model do
  subject(:contact) { build(:contact_app_contact, user: user, firstname: 'John', lastname: 'DOE') }

  let(:user) { create(:user) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(trashed: 0, published: 1) }
  end

  describe '#fullname' do
    it 'returns titleized firstname and uppercased lastname' do
      expect(contact.fullname).to eq('John DOE')
    end

    it 'handles nil firstname gracefully' do
      contact.firstname = nil
      expect(contact.fullname).to eq(' DOE')
    end
  end

  describe '#to_vcard' do
    it 'returns a vCard string' do
      contact.save!
      vcard = contact.to_vcard
      expect(vcard).to include('BEGIN:VCARD')
      expect(vcard).to include('END:VCARD')
    end
  end
end
