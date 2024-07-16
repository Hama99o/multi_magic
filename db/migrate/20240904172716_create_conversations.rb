class CreateConversations < ActiveRecord::Migration[7.0]
  def change
    create_table :conversations do |t|
      t.integer :sender_id
      t.integer :recipient_id
      t.datetime :sender_deleted_at
      t.datetime :recipient_deleted_at

      t.timestamps
    end
  end
end
