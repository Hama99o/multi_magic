class CreateMyFinanceAppLoanPayments < ActiveRecord::Migration[7.0]
  def change
    create_table :my_finance_app_loan_payments do |t|
      t.references :loan, foreign_key: { to_table: :my_finance_app_loans }
      t.decimal :amount
      t.datetime :payment_date

      t.timestamps
    end
  end
end
