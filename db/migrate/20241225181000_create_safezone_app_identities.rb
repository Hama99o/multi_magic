class CreateSafezoneAppIdentities < ActiveRecord::Migration[7.0]
  def change
    create_table :safezone_app_identities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :type, null: false # e.g., "SafezoneApp::Identities::Passport"
      t.string :document_number, null: false, unique: true
      t.date :issued_at
      t.date :expires_at
      t.string :image # Path to uploaded image
      t.jsonb :data, default: {} # Store flexible fields

      t.timestamps
    end
  end
end
