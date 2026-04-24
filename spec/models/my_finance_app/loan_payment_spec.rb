# == Schema Information
#
# Table name: my_finance_app_loan_payments
#
#  id           :integer          not null, primary key
#  loan_id      :integer
#  amount       :decimal(, )
#  payment_date :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_my_finance_app_loan_payments_on_loan_id  (loan_id)
#

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MyFinanceApp::LoanPayment, type: :model do
  subject(:loan_payment) { build(:loan_payment, loan: loan) }

  let(:user) { create(:user) }
  let(:loan) { create(:loan, user: user) }

  describe 'associations' do
    it { is_expected.to belong_to(:loan).class_name('MyFinanceApp::Loan') }
  end

  describe 'creation' do
    it 'is valid with a loan' do
      expect(loan_payment).to be_valid
    end

    it 'persists to the database' do
      expect { loan_payment.save }.to change(described_class, :count).by(1)
    end
  end
end
