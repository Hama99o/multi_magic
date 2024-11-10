# app/serializers/blog_app/articles/bookmark_serializer.rb
class BlogApp::Articles::BookmarkSerializer < ApplicationSerializer
  identifier :id
  fields :created_at

  association :user, blueprint: UserSerializer, view: :public

  # field :bookmarkable do |bookmark|
  #   case bookmark.bookmarkable_type
  #   when 'BlogApp::Article'
  #     BlogApp::Articles::ArticleSerializer.render_as_hash(bookmark.bookmarkable)
  #   when 'Comment'
  #     CommentSerializer.render_as_hash(bookmark.bookmarkable)
  #   # Add more types if there are other bookmarkable models
  #   else
  #     nil
  #   end
  # end
end
