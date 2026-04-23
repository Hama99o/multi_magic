# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SafezoneApp::PaymentCard, type: :model do
  subject(:payment_card) { build(:payment_card, owner: user) }

  let(:user) { create(:user) }

  describe 'associations' do
    it { is_expected.to belong_to(:owner).class_name('User') }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(trashed: 0, published: 1) }
    it { is_expected.to define_enum_for(:card_type).with_values(credit_card: 0, debit_card: 1) }
  end

  describe 'before_create :set_default_value_of_data' do
    it 'sets note to empty string when not provided' do
      card = create(:payment_card, owner: user, note: nil)
      expect(card.note).to eq('')
    end

    it 'preserves existing note when provided' do
      card = create(:payment_card, owner: user, note: 'My card')
      expect(card.note).to eq('My card')
    end
  end
end
