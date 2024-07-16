# == Schema Information
#
# Table name: my_finance_app_expenses
#
#  id             :bigint           not null, primary key
#  user_id        :bigint           not null
#  item           :string           not null
#  amount         :decimal(10, 2)   not null
#  description    :string
#  tag_id         :bigint
#  currency       :integer          default("eur"), not null
#  deleted_at     :datetime
#  status         :integer          default("trashed"), not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  subcategory_id :bigint
#  spent_at       :datetime
#
# Indexes
#
#  index_my_finance_app_expenses_on_tag_id   (tag_id)
#  index_my_finance_app_expenses_on_user_id  (user_id)
#
FactoryBot.define do
  factory :expense, class: 'MyFinanceApp::Expense' do
    item { Faker::Book.title }
    description { Faker::Lorem.paragraph }
    amount { Faker::Number.decimal(l_digits: 3, r_digits: 3)}
    user factory: %i[user]
    status { :published }
    tag factory: %i[my_finance_app_tag]
  end
end
