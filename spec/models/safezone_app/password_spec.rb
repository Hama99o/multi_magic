# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SafezoneApp::Password, type: :model do
  subject(:password) { build(:safezone_app_passwords, owner: user) }

  let(:user) { create(:user) }

  describe 'associations' do
    it { is_expected.to belong_to(:owner).class_name('User') }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(trashed: 0, published: 1) }
  end

  describe 'creation' do
    it 'is valid with an owner' do
      expect(password).to be_valid
    end
  end
end
