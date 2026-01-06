# == Schema Information
#
# Table name: todo_app_todo_groups
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  name       :string           not null
#  position   :integer          default(0)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_todo_app_todo_groups_on_user_id  (user_id)
#
class TodoApp::TodoGroupSerializer < ApplicationSerializer
  identifier :id

  fields :name, :position, :created_at, :updated_at

  field :todos_count do |group|
    group.todos.active.count
  end

  field :completed_count do |group|
    group.todos.active.completed.count
  end

  field :pending_count do |group|
    group.todos.active.pending.count
  end

  # Full todos - used when viewing a single group
  view :with_todos do
    association :todos, blueprint: TodoApp::TodoSerializer do |group|
      group.todos.active.order(position: :asc)
    end
  end

  # Preview todos - limited to 3 pending items for grid card display
  view :with_preview_todos do
    field :preview_todos do |group|
      todos = group.todos.active.pending.order(position: :asc).limit(3)
      TodoApp::TodoSerializer.render_as_hash(todos)
    end
  end
end
