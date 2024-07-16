class Api::V1::BlogApp::Articles::CommentsController < ApplicationController
  before_action :set_article
  before_action :set_comment, only: [:update, :destroy]
  before_action :authorize_comment, only: [:update, :destroy]
  skip_before_action :authenticate_user!, only: [:index, :show]

  # GET /articles/:article_id/comments
  def index
    @comments = @article.comments.where(parent_id: nil).includes(:replies, :user)

    paginate_render(
      CommentSerializer,
      @comments,
      extra: {
        root: :comments,
        current_user: current_user
      }
    )
  end

  # POST /articles/:article_id/comments
  def create
    @comment = @article.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      render json: {
        comment: CommentSerializer.render_as_hash(@comment)
      }, status: :ok
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /articles/:article_id/comments/:id
  def update
    if @comment.user == current_user && @comment.update(comment_params)
      render json: {
        comment: CommentSerializer.render_as_hash(@comment)
      }, status: :ok
    else
      render json: { error: 'Unable to update comment' }, status: :forbidden
    end
  end

  # DELETE /articles/:article_id/comments/:id
  def destroy
    if @comment.user == current_user
      @comment.destroy
      render json: {
        comment: CommentSerializer.render_as_hash(@comment)
      }, status: :ok
    else
      render json: { error: 'Not authorized to delete this comment' }, status: :forbidden
    end
  end

  private

  def set_article
    @article = BlogApp::Article.find(params[:article_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Article not found' }, status: :not_found
  end

  def set_comment
    @comment = @article.comments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Comment not found' }, status: :not_found
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end

  def authorize_comment
    authorize @comment, policy_class: BlogApp::ArticleCommentPolicy  # Specifies the ArticleCommentPolicy
  end
end
