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
FactoryBot.define do
  factory :loan, class: 'MyFinanceApp::Loan' do
    description { Faker::Lorem.paragraph }
    loan_type { 0 }
    due_date { Faker::Date.between(from: 2.days.ago, to: Date.today) }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 3)}
    user factory: %i[user]
    status { :paid }
    contact factory: %i[contact]
  end
end
