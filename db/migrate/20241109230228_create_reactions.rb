class CreateReactions < ActiveRecord::Migration[7.0]
  def change
    create_table :reactions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :type
      t.references :reactionable, polymorphic: true, null: false
      t.integer :reaction_type

      t.timestamps
    end
  end
end
