class CreateMyFinanceAppExpenses < ActiveRecord::Migration[7.0]
  def change
    create_table :my_finance_app_expenses do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :item, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :description
      t.references :tag, foreign_key: true, index: true
      t.integer :currency, null: false, default: 0  # Adding currency with a default value
      t.datetime :deleted_at
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
