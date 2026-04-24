# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SafezoneApp::Identity, type: :model do
  subject(:identity) { build(:identity, user: user) }

  let(:user) { create(:user) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:document_number) }
  end

  describe 'before_create :set_default_value_of_data' do
    it 'sets note to empty string when not provided' do
      identity = create(:identity, user: user, note: nil)
      expect(identity.note).to eq('')
    end
  end

  describe 'store_accessor' do
    it 'can read and write note via store accessor' do
      identity.note = 'some note'
      expect(identity.note).to eq('some note')
    end
  end
end
