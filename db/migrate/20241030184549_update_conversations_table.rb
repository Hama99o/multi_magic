class UpdateConversationsTable < ActiveRecord::Migration[6.1]
  def up
    # Remove old columns
    remove_column :conversations, :sender_id, :integer
    remove_column :conversations, :recipient_id, :integer
    remove_column :conversations, :sender_deleted_at, :datetime
    remove_column :conversations, :recipient_deleted_at, :datetime

    # Add new columns
    add_column :conversations, :is_group, :boolean, default: false, null: false
    add_column :conversations, :title, :string

    # Add index for is_group
    add_index :conversations, :is_group
  end

  def down
    # Add old columns back
    add_column :conversations, :sender_id, :integer
    add_column :conversations, :recipient_id, :integer
    add_column :conversations, :sender_deleted_at, :datetime
    add_column :conversations, :recipient_deleted_at, :datetime

    # Remove new columns
    remove_column :conversations, :is_group, :boolean
    remove_column :conversations, :title, :string

    # Remove index if it exists
    remove_index :conversations, :is_group if index_exists?(:conversations, :is_group)
  end
end
