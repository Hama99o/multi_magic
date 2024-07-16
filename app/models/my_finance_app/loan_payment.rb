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
class MyFinanceApp::LoanPayment < ApplicationRecord
  belongs_to :loan, class_name: 'MyFinanceApp::Loan'
end
