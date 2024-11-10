# app/controllers/api/v1/blog_app/articles/bookmarks_controller.rb
class Api::V1::BlogApp::Articles::BookmarksController < ApplicationController
  before_action :set_article
  skip_before_action :authenticate_user!, only: [:index]

  # GET /articles/:article_id/bookmarks
  def index
    @bookmarks = @article.bookmarks

    paginate_render(
      BlogApp::Articles::BookmarkSerializer,
      @bookmarks,
      extra: {
        root: :bookmarks,
        current_user: current_user
      }
    )
  end

  # POST /articles/:article_id/bookmarks
  def create
    # Initialize a bookmark for the current user on this article
    @bookmark = @article.bookmarks.find_or_initialize_by(user: current_user)
    authorize @bookmark

    if @bookmark.persisted?
      render json: { error: 'Bookmark already exists' }, status: :unprocessable_entity
    elsif @bookmark.save
      render json: {
        bookmark: BlogApp::Articles::BookmarkSerializer.render_as_hash(@bookmark)
      }, status: :created
    else
      render json: @bookmark.errors, status: :unprocessable_entity
    end
  end

  # DELETE /articles/:article_id/bookmarks
  def destroy
    bookmarks = @article.bookmarks.where(user: current_user)
    # authorize @bookmark

    if bookmarks.destroy_all
      render json: {
        bookmarks: bookmarks

      }, status: :ok
    else
      render json: { error: 'Not authorized to delete this bookmark' }, status: :forbidden
    end
  end

  private

  def set_article
    @article = BlogApp::Article.find(params[:article_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Article not found' }, status: :not_found
  end

  def set_bookmark
    @bookmark = @article.bookmarks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Bookmark not found' }, status: :not_found
  end
end
