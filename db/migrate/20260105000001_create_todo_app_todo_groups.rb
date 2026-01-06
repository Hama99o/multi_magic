class CreateTodoAppTodoGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :todo_app_todo_groups do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :name, null: false
      t.integer :position, default: 0
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
