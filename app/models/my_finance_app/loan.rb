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
class MyFinanceApp::Loan < ApplicationRecord
  belongs_to :user, class_name: "User"
  belongs_to :contact, class_name: "Contact", optional: true
  belongs_to :tag, class_name: "MyFinanceApp::Tag", optional: true
  has_many :loan_payments, class_name: 'MyFinanceApp::LoanPayment', dependent: :destroy

  enum loan_type: {
    given: 0,
    taken: 1
  }

  enum status: {
    trashed: 0,
    paid: 1,
    unpaid: 2
  }

  enum currency: {
    eur: 0,
    usd: 1,
    gbp: 2,
    afn: 3,
    pkr: 4,
    inr: 5,
    jpy: 6,
    cny: 7
  }
  include PgSearch::Model
  pg_search_scope :search_loans,
                  against: [:contact_name, :description, :amount],
                  associated_against: {
                    tag: %i[name]
                  },
                  using: {
                    tsearch: { prefix: true }
                  }


                  has_many :loan_payments, dependent: :destroy

  def total_paid
    O if !loan_payments
    loan_payments.sum(:amount)
  end

  def remaining_amount
    (amount || 0) - total_paid
  end
end
