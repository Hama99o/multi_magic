# == Schema Information
#
# Table name: my_finance_app_loan_payments
#
#  id           :bigint           not null, primary key
#  loan_id      :bigint
#  amount       :decimal(, )
#  payment_date :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_my_finance_app_loan_payments_on_loan_id  (loan_id)
#
FactoryBot.define do
  factory :loan_payment, class: 'MyFinanceApp::LoanPayment' do
    loan { nil }
    amount { "9.99" }
    payment_date { "2024-09-02 13:48:48" }
  end
end
