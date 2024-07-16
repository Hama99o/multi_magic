class CreateNoteAppReminders < ActiveRecord::Migration[7.0]
  def change
    create_table :note_app_reminders do |t|
      t.references :note, foreign_key: { to_table: :note_app_notes }
      t.references :user, foreign_key: true
      t.datetime :reminder_time
      t.boolean :is_completed, default: false

      t.timestamps
    end
  end
end
