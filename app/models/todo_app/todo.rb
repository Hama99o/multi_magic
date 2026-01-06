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
class TodoApp::Todo < ApplicationRecord
  belongs_to :todo_group, class_name: 'TodoApp::TodoGroup'
  belongs_to :user

  validates :title, presence: true

  acts_as_list scope: :todo_group

  scope :active, -> { where(deleted_at: nil) }
  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }

  include PgSearch::Model
  pg_search_scope :search_todos,
                  against: [:title, :notes],
                  using: {
                    tsearch: { prefix: true }
                  }
end
