# app/controllers/api/v1/blog_app/articles/reactions_controller.rb
class Api::V1::BlogApp::Articles::ReactionsController < ApplicationController
  before_action :set_article

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
    @reaction = @article.reactions.find_or_initialize_by(user: current_user, type: 'Reaction::Like')
    authorize @reaction  # Ensure authorization before proceeding

    if @reaction.persisted?
      render json: { error: 'Reaction already exists' }, status: :unprocessable_entity
    elsif @reaction.save
      render json: {
        reaction: BlogApp::Articles::ReactionSerializer.render_as_hash(@reaction)
      }, status: :created
    else
      render json: @reaction.errors, status: :unprocessable_entity
    end
  end

  # DELETE /articles/:article_id/reactions
  def destroy
    reactions = @article.reactions.where(user_id: current_user.id)
    # authorize reaction

    if reactions&.destroy_all
      render json: { reactions: reactions }
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
end
