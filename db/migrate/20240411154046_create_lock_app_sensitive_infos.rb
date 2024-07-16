class CreateLockAppSensitiveInfos < ActiveRecord::Migration[7.0]
  def change
    create_table :lock_app_sensitive_infos do |t|
      t.references :user, null: false, foreign_key: true
      t.string :data_type
      t.text :data
      t.string :username
      t.string :link
      t.string :email
      t.text :description

      t.timestamps
    end
  end
end
