class AddUserIdAndParentIdToTags < ActiveRecord::Migration[6.1]
  def change
    add_reference :tags, :user, index: true, foreign_key: true
    add_column :tags, :parent_id, :bigint, index: true
    add_foreign_key :tags, :tags, column: :parent_id # self-referencing foreign key
  end
end
