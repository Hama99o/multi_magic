class CreateSafezoneAppCards < ActiveRecord::Migration[7.0]
  def change
    create_table :safezone_app_cards do |t|
      t.references :owner, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false
      t.string :name
      t.integer :type, default: 0, null: false
      t.string :account_number
      t.string :expiry_date
      t.datetime :deleted_at
      t.jsonb :note

      t.timestamps
    end
  end
end
