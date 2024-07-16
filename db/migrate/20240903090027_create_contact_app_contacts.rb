class CreateContactAppContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :contact_app_contacts do |t|
      t.integer :user_id, null: true, foreign_key: true
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :phone
      t.string :address
      t.date :birth_date
      t.integer :status, default: 0, null: false
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
