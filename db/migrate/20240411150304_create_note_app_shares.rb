class CreateNoteAppShares < ActiveRecord::Migration[7.0]
  def change
    create_table :note_app_shares do |t|
      t.references :note, foreign_key: { to_table: :note_app_notes }
      t.references :shared_with_user, foreign_key: { to_table: :users }
      t.integer :role, default: 0, null: false

      t.timestamps
    end
  end
end
