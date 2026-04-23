# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contact, type: :model do
  subject(:contact) { build(:contact) }

  describe 'associations' do
    it { is_expected.to belong_to(:user).optional }
  end

  describe 'creation' do
    it 'is valid without a user' do
      expect(contact).to be_valid
    end

    it 'is valid with a user' do
      contact.user = create(:user)
      expect(contact).to be_valid
    end
  end
end
