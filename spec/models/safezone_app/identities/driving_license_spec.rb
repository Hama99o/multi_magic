# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SafezoneApp::Identities::DrivingLicense, type: :model do
  let(:user) { create(:user) }

  describe 'inheritance' do
    it 'inherits from SafezoneApp::Identity' do
      expect(described_class.superclass).to eq(SafezoneApp::Identity)
    end
  end

  describe 'creation' do
    it 'can be created with required attributes' do
      dl = described_class.create!(user: user, document_number: 'DL-12345')
      expect(dl.type).to eq('SafezoneApp::Identities::DrivingLicense')
    end
  end
end
