# == Schema Information
#
# Table name: comments
#
#  id               :bigint           not null, primary key
#  body             :text
#  user_id          :bigint           not null
#  parent_id        :bigint
#  commentable_type :string           not null
#  commentable_id   :bigint           not null
#  data             :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_comments_on_commentable_type_and_commentable_id  (commentable_type,commentable_id) UNIQUE
#  index_comments_on_parent_id                            (parent_id)
#  index_comments_on_user_id                              (user_id)
#
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true  # Polymorphic association
  belongs_to :user

  # Self-referencing association for replies
  belongs_to :parent, class_name: 'Comment', optional: true
  has_many :replies, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy

  validates :body, presence: true
end
