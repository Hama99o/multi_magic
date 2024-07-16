class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.references :conversation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body
      t.datetime :read_at
      t.datetime :sender_deleted_at
      t.datetime :recipient_deleted_at
      
      t.timestamps
    end
  end
end
