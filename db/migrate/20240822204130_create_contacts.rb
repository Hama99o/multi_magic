class CreateContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :email
      t.string :phone_number
      t.integer :user_id, null: true, foreign_key: true
      t.datetime :deleted_at
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :contacts, :user_id
  end
end
