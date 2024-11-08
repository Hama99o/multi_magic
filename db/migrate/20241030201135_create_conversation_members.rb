class CreateConversationMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :conversation_members do |t|
      t.bigint :conversation_id, null: false
      t.bigint :user_id, null: false
      t.integer :status, default: 0, null: false
      t.datetime :last_read_at                # Tracks the last time each member read the conversation
      t.datetime :deleted_at                  # Soft delete for user-specific deletion of the conversation
      t.datetime :soft_deleted_at             # This column will be set whenever a user soft-deletes a conversation and cleared when they restore or rejoin it.
      t.boolean :is_admin, default: false     # Indicates if the user is an admin in a group conversation
      t.timestamps                            # Adds created_at and updated_at automatically

      # Indexes for faster querying
      t.index :conversation_id, name: "index_conversation_members_on_conversation_id"
      t.index :user_id, name: "index_conversation_members_on_user_id"
      t.index [:conversation_id, :user_id], unique: true, name: "index_conversation_members_on_conversation_and_user"
    end
  end
end
