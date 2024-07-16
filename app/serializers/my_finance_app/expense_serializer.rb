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
class MyFinanceApp::ExpenseSerializer < ApplicationSerializer
  identifier :id
  fields :item, :description, :amount, :currency, :spent_at, :deleted_at, :tag_id, :subcategory_id

  field :category do |expense|
    expense.tag.name
  end

  field :tag do |loan|
    next nil if !loan.tag
    TagSerializer.render_as_hash(loan.tag)
  end

  field :subcategory do |loan|
    next nil if !loan.subcategory
    TagSerializer.render_as_hash(loan.subcategory)
  end

  field :amount_with_currency do |expense|
    "#{ expense.amount } #{expense.currency}"
  end
end
