# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MyFinanceApp::Loan, type: :model do
  subject(:loan) { build(:loan, user: user) }

  let(:user) { create(:user) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:contact).optional }
    it { is_expected.to belong_to(:tag).class_name('MyFinanceApp::Tag').optional }
    it { is_expected.to have_many(:loan_payments).dependent(:destroy) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:loan_type).with_values(given: 0, taken: 1) }
    it { is_expected.to define_enum_for(:status).with_values(trashed: 0, paid: 1, unpaid: 2) }

    it {
      expect(subject).to define_enum_for(:currency)
        .with_values(eur: 0, usd: 1, gbp: 2, afn: 3, pkr: 4, inr: 5, jpy: 6, cny: 7)
    }
  end

  describe '#total_paid' do
    it 'returns 0 when there are no payments' do
      loan.save!
      expect(loan.total_paid).to eq(0)
    end

    it 'returns the sum of all loan payment amounts' do
      loan.save!
      create(:loan_payment, loan: loan, amount: 100)
      create(:loan_payment, loan: loan, amount: 50)
      expect(loan.total_paid).to eq(150)
    end
  end

  describe '#remaining_amount' do
    it 'returns the full amount when no payments exist' do
      loan.amount = 500
      loan.save!
      expect(loan.remaining_amount).to eq(500)
    end

    it 'returns amount minus total paid' do
      loan.amount = 500
      loan.save!
      create(:loan_payment, loan: loan, amount: 200)
      expect(loan.remaining_amount).to eq(300)
    end
  end
end
