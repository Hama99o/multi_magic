class AddIsAiToConversations < ActiveRecord::Migration[7.0]
  def change
    add_column :conversations, :is_ai, :boolean, default: false
  end
end
