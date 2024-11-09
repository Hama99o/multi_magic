# app/controllers/api/v1/blog_app/articles/reactions_controller.rb
class Api::V1::BlogApp::Articles::ReactionsController < ApplicationController
  before_action :set_article
  before_action :set_reaction, only: [:destroy]
  before_action :authorize_reaction, only: [:destroy]
  skip_before_action :authenticate_user!, only: [:index]

  # GET /articles/:article_id/reactions
  def index
    @reactions = @article.reactions.includes(:user)

    paginate_render(
      BlogApp::Articles::ReactionSerializer,
      @reactions,
      extra: {
        root: :reactions,
        current_user: current_user
      }
    )
  end

  # POST /articles/:article_id/reactions
  def create
    # Find or initialize a reaction of a given type for the current user on this article
    @reaction = @article.reactions.find_or_initialize_by(user: current_user, reaction_type: reaction_params[:reaction_type])

    if authorize(@reaction).persisted?
      render json: { error: 'Reaction already exists' }, status: :unprocessable_entity
    elsif @reaction.save
      render json: {
        reaction: BlogApp::Articles::ReactionSerializer.render_as_hash(@reaction)
      }, status: :created
    else
      render json: @reaction.errors, status: :unprocessable_entity
    end
  end

  # DELETE /articles/:article_id/reactions/:id
  def destroy
    if authorize(@reaction).user == current_user
      @reaction.destroy
      render json: {
        reaction: BlogApp::Articles::ReactionSerializer.render_as_hash(@reaction)
      }, status: :ok
    else
      render json: { error: 'Not authorized to delete this reaction' }, status: :forbidden
    end
  end

  private

  def set_article
    @article = BlogApp::Article.find(params[:article_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Article not found' }, status: :not_found
  end

  def set_reaction
    @reaction = @article.reactions.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Reaction not found' }, status: :not_found
  end

  def reaction_params
    params.require(:reaction).permit(:reaction_type)
  end

  def authorize_reaction
    authorize @reaction, policy_class: BlogApp::ArticleReactionPolicy  # Specifies the ArticleReactionPolicy
  end
end
