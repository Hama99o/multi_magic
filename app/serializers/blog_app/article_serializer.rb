# == Schema Information
#
# Table name: blog_app_articles
#
#  id           :bigint           not null, primary key
#  title        :string
#  subtitle     :text
#  published_at :datetime
#  user_id      :bigint           not null
#  deleted_at   :datetime
#  status       :integer          default("trashed"), not null
#  description  :jsonb
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_blog_app_articles_on_user_id  (user_id)
#
class BlogApp::ArticleSerializer < ApplicationSerializer
  identifier :id
  fields :title, :description, :user_id, :subtitle, :published_at, :created_at, :updated_at, :tag_ids, :status
  association :user, blueprint: UserSerializer, view: :private

  field :tags do |article, options|
    TagSerializer.render_as_hash(article.tags)
  end

  field :cover_photo do |article|
    article.get_cover_photo_url.presence if article&.cover_photo&.attached?
  end
end
