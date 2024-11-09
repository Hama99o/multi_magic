class RemoveDuplicateIndexOnComments < ActiveRecord::Migration[7.0]
  def change
    remove_index :comments, name: "index_comments_on_commentable"
  end
end
