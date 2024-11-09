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
#  index_comments_on_commentable_type_and_commentable_id  (commentable_type,commentable_id)
#  index_comments_on_parent_id                            (parent_id)
#  index_comments_on_user_id                              (user_id)
#
class CommentSerializer < ApplicationSerializer
  identifier :id
  fields :body, :user_id, :parent_id, :created_at, :updated_at

  association :user, blueprint: UserSerializer, view: :public

  field :replies do |comment, _options|
    CommentSerializer.render_as_hash(comment.replies)
  end
end
