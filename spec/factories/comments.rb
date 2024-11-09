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
FactoryBot.define do
  factory :comment do
    body { "MyText" }
    user factory: %i[user]
  end
end
