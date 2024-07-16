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
class MyFinanceApp::Expense < ApplicationRecord
  belongs_to :user, class_name: "User"
  belongs_to :tag, class_name: "MyFinanceApp::Tag"
  belongs_to :subcategory, class_name: "MyFinanceApp::Tag", optional: true, foreign_key: :subcategory_id

  validates :amount, numericality: { greater_than_or_equal_to: 0 }

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

  enum status: {
    trashed: 0,
    published: 1
  }

  include PgSearch::Model
  pg_search_scope :search_expenses,
                  against: [:item, :description],
                  associated_against: {
                    tag: %i[name]
                  },
                  using: {
                    tsearch: { prefix: true }
                  }

  def self.pie_chart_data_by_tag
    expenses = MyFinanceApp::Expense.joins(:tag).group('tags.name').sum(:amount)

    chart_data = expenses.map do |category, amount|
      { category: category, amount: amount }
    end

    chart_data
  end

  def self.total_amount_last_years(current_user)
    current_year = Date.today.year
    start_year = current_year - 9
    # start_year = current_year - 2

    expenses = current_user.expenses.where(status: :published)
                 .where('extract(year from created_at) BETWEEN ? AND ?', start_year, current_year)
                 .group("extract(year from created_at)")
                 .sum(:amount)

    # Converting keys (year) to integer and returning the data as a hash
    expenses.transform_keys { |year| year.to_i }
  end

  def self.total_amount_last_months(current_user)
    end_date = Date.today
    start_date = end_date - 11.months

    expenses = current_user.expenses.where(status: :published)
                   .where('created_at BETWEEN ? AND ?', start_date.beginning_of_month, end_date.end_of_month)
                   .group("DATE_TRUNC('month', created_at)")
                   .sum(:amount)

    # Formatting the keys to display in YYYY-MM format
    expenses.transform_keys { |date| date.strftime('%Y-%m') }
  end
end
