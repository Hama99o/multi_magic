class RemoveUniqueIndexFromComments < ActiveRecord::Migration[7.0]
  def up
    # Remove the unique index on commentable_type and commentable_id
    remove_index :comments, column: [:commentable_type, :commentable_id], name: "index_comments_on_commentable_type_and_commentable_id"

    # Optionally, add a non-unique index if you need this combination indexed but not enforced as unique
    add_index :comments, [:commentable_type, :commentable_id]
  end

  def down
    # Re-add the unique index in case of rollback
    remove_index :comments, column: [:commentable_type, :commentable_id]
    add_index :comments, [:commentable_type, :commentable_id], unique: true, name: "index_comments_on_commentable_type_and_commentable_id"
  end
end
