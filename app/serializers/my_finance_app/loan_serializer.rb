# == Schema Information
#
# Table name: my_finance_app_loans
#
#  id           :bigint           not null, primary key
#  user_id      :integer
#  due_date     :date
#  amount       :decimal(15, 2)
#  description  :string
#  loan_type    :integer          default("given"), not null
#  contact_name :string
#  contact_id   :integer
#  currency     :integer          default("eur"), not null
#  deleted_at   :datetime
#  status       :integer          default("trashed"), not null
#  tag_id       :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_my_finance_app_loans_on_contact_id  (contact_id)
#  index_my_finance_app_loans_on_tag_id      (tag_id)
#  index_my_finance_app_loans_on_user_id     (user_id)
#
class MyFinanceApp::LoanSerializer < ApplicationSerializer
  identifier :id
  fields :description , :due_date, :description, :amount, :contact_name, :loan_type, :status, :currency, :tag_id, :total_paid, :remaining_amount

  field :category do |loan|
    loan.tag&.name
  end


  field :category do |loan|
    loan.tag&.name
  end

  field :loan_payments do |loan|
    next nil if !loan.loan_payments
    loan.loan_payments.order(payment_date: :asc).as_json
  end

  field :amount_with_currency do |loan|
    "#{ loan.amount } #{loan.currency}"
  end
end
