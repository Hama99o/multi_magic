class CreateTodoAppTodos < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_app_todos do |t|
      t.references :todo_group, null: false, foreign_key: { to_table: :todo_app_todo_groups }, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.string :title, null: false
      t.text :notes
      t.boolean :completed, default: false, null: false
      t.integer :position, default: 0
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
