class Comments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.text :body
      t.references :user, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :comments }, index: true
      t.references :commentable, polymorphic: true, null: false
      t.jsonb :data

      t.timestamps
    end
    add_index :comments, [:commentable_type, :commentable_id]
  end
end
