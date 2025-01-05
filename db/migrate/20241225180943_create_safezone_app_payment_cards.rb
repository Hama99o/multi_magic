class CreateSafezoneAppPaymentCards < ActiveRecord::Migration[7.0]
  def change
    create_table :safezone_app_payment_cards do |t|
      t.references :owner, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false
      t.string :name
      t.integer :card_type, default: 0, null: false
      t.string :card_number
      t.string :cvv
      t.string :expiry_date
      t.datetime :deleted_at
      t.jsonb :note

      t.timestamps
    end
  end
end
