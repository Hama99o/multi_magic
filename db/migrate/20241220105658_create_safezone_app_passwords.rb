class CreateSafezoneAppPasswords < ActiveRecord::Migration[7.0]
  def change
    create_table :safezone_app_passwords do |t|
      t.references :owner, foreign_key: { to_table: :users }
      t.integer :status, default: 0, null: false
      t.jsonb :data
      t.string :title
      t.string :email
      t.string :link
      t.string :username
      t.jsonb :note
      t.datetime :deleted_at
      t.string :password

      t.timestamps
    end
  end
end
