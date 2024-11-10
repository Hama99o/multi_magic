# app/controllers/api/v1/blog_app/users/bookmarks_controller.rb
class Api::V1::BlogApp::Users::BookmarksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_bookmark, only: [:destroy]

  # GET /users/bookmarks/articles
  def user_article_bookmarks
    @bookmarks = current_user.bookmarks.where(bookmarkable_type: 'BlogApp::Article').includes(:bookmarkable)

    paginate_render(
      BlogApp::Articles::BookmarkSerializer,
      policy_scope(@bookmarks)
    )
  end

  # DELETE /users/bookmarks/articles/:id
  def destroy
    if @bookmark.user == current_user
      @bookmark.destroy
      render json: { message: 'Bookmark deleted successfully' }, status: :ok
    else
      render json: { error: 'Not authorized to delete this bookmark' }, status: :forbidden
    end
  end

  private

  def set_bookmark
    @bookmark = current_user.bookmarks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Bookmark not found' }, status: :not_found
  end
end
