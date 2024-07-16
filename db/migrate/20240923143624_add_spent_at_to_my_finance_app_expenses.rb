class AddSpentAtToMyFinanceAppExpenses < ActiveRecord::Migration[7.0]
  def change
    add_column :my_finance_app_expenses, :spent_at, :datetime
  end
end
