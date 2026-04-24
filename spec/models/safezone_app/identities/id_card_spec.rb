# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SafezoneApp::Identities::IdCard, type: :model do
  let(:user) { create(:user) }

  describe 'inheritance' do
    it 'inherits from SafezoneApp::Identity' do
      expect(described_class.superclass).to eq(SafezoneApp::Identity)
    end
  end

  describe 'creation' do
    it 'can be created with required attributes' do
      card = described_class.create!(user: user, document_number: 'ID-99999')
      expect(card.type).to eq('SafezoneApp::Identities::IdCard')
    end
  end
end
