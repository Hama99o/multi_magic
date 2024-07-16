class CreateMyFinanceAppLoans < ActiveRecord::Migration[7.0]
  def change
    create_table :my_finance_app_loans do |t|
      t.integer :user_id, null: true, foreign_key: true
      t.date :due_date
      t.decimal :amount, precision: 15, scale: 2 # precision and scale can be adjusted based on needs
      t.string :description
      t.integer :loan_type, null: false, default: 0 # considering it as a string, but you might want to make it an enum in the model
      t.string :contact_name
      t.integer :contact_id, null: true, foreign_key: true # null: true allows it to be optional
      t.integer :currency, null: false, default: 0  # Adding currency with a default value
      t.datetime :deleted_at
      t.integer :status, default: 0, null: false
      t.references :tag, foreign_key: true, index: true

      t.timestamps
    end

    add_index :my_finance_app_loans, :user_id
    add_index :my_finance_app_loans, :contact_id
  end
end
