# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MyFinanceApp::Expense, type: :model do
  subject(:expense) { build(:expense, user: user, tag: tag) }

  let(:user) { create(:user) }
  let(:tag) { create(:my_finance_app_tag, user: user) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:tag).class_name('MyFinanceApp::Tag') }
    it { is_expected.to belong_to(:subcategory).class_name('MyFinanceApp::Tag').optional }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:amount).is_greater_than_or_equal_to(0) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(trashed: 0, published: 1) }

    it {
      expect(subject).to define_enum_for(:currency)
        .with_values(eur: 0, usd: 1, gbp: 2, afn: 3, pkr: 4, inr: 5, jpy: 6, cny: 7)
    }
  end

  describe '.pie_chart_data_by_tag' do
    it 'returns an array of category/amount hashes' do
      create(:expense, user: user, tag: tag, amount: 100, status: :published)
      result = described_class.pie_chart_data_by_tag
      expect(result).to be_an(Array)
      expect(result.first).to have_key(:category)
      expect(result.first).to have_key(:amount)
    end
  end

  describe '.total_amount_last_years' do
    it 'returns a hash keyed by year' do
      create(:expense, user: user, tag: tag, amount: 250, status: :published, created_at: Time.zone.now)
      result = described_class.total_amount_last_years(user)
      expect(result).to be_a(Hash)
      expect(result[Time.zone.today.year]).to eq(250)
    end
  end
end
