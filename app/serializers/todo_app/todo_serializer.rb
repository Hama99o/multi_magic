# == Schema Information
#
# Table name: todo_app_todos
#
#  id            :bigint           not null, primary key
#  todo_group_id :bigint           not null
#  user_id       :bigint           not null
#  title         :string           not null
#  notes         :text
#  completed     :boolean          default(FALSE), not null
#  position      :integer          default(0)
#  deleted_at    :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_todo_app_todos_on_todo_group_id  (todo_group_id)
#  index_todo_app_todos_on_user_id        (user_id)
#
class TodoApp::TodoSerializer < ApplicationSerializer
  identifier :id

  fields :title, :notes, :completed, :position, :todo_group_id, :created_at, :updated_at
end
