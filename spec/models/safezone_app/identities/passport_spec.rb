# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SafezoneApp::Identities::Passport, type: :model do
  let(:user) { create(:user) }

  describe 'inheritance' do
    it 'inherits from SafezoneApp::Identity' do
      expect(described_class.superclass).to eq(SafezoneApp::Identity)
    end
  end

  describe 'creation' do
    it 'can be created with required attributes' do
      passport = described_class.create!(user: user, document_number: 'PP-777888')
      expect(passport.type).to eq('SafezoneApp::Identities::Passport')
    end
  end
end
