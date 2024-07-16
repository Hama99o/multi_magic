class CreateNotesTagsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_table :notes_tags, id: false do |t|
      t.belongs_to :note, foreign_key: { to_table: :note_app_notes }
      t.belongs_to :tag
    end
  end
end
