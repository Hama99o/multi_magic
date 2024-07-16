class AddSubcategoryToMyFinanceAppExpenses < ActiveRecord::Migration[7.0]
  def change
    add_column :my_finance_app_expenses, :subcategory_id, :bigint
    add_foreign_key :my_finance_app_expenses, :tags, column: :subcategory_id
  end
end
