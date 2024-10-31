class RemoveDeletedAtFieldsFromMessages < ActiveRecord::Migration[7.0]
  def change
    remove_column :messages, :sender_deleted_at, :datetime
    remove_column :messages, :recipient_deleted_at, :datetime
  end
end
