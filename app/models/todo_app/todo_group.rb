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
class TodoApp::TodoGroup < ApplicationRecord
  belongs_to :user
  has_many :todos, class_name: 'TodoApp::Todo', foreign_key: :todo_group_id, dependent: :destroy

  validates :name, presence: true

  acts_as_list scope: :user

  scope :active, -> { where(deleted_at: nil) }

  include PgSearch::Model
  pg_search_scope :search_groups,
                  against: [:name],
                  using: {
                    tsearch: { prefix: true }
                  }
end
