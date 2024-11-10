class Api::V1::BlogApp::ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :update, :destroy, :restore, :destroy_permanently, :toggle_tag]
  skip_before_action :authenticate_user!, only: [:index, :show]

  # GET /articles
  def index
    @articles = BlogApp::Article.where(status: :published)

    article_index(@articles, :published)
  end

  # GET /articles/trashes
  def trashes
    articles = current_user.articles.where(status: :trashed)

    article_index(articles, :trashed)
  end

  # GET /articles/drafts
  def drafts
    articles = current_user.articles.where(status: :draft)

    article_index(articles, :trashed)
  end

  # GET /articles/:id
  def show
    record_view(@article, user: current_user, ip_address: request.remote_ip, user_agent: request.user_agent)

    render json: {
      article: BlogApp::ArticleSerializer.render_as_json(authorize(@article), current_user: current_user)
    }, status: :ok
  end

  def toggle_tag
    @article.taggings.destroy_all
    tags_ids = params[:tag_ids]
    if tags_ids.present?
      tags_ids.each do |tag_id|
        tag = BlogApp::Tag.find(tag_id)

        if !Tagging.find_by(tag:, taggable: @article).present?
          Tagging.create(tag:, taggable: @article)
        end
      end
    end
    render json: {
      article: BlogApp::ArticleSerializer.render_as_json(authorize(@article), current_user: current_user)
    }, status: :ok
  end

  # POST /articles
  def create
    @article = BlogApp::Article.new(article_params.merge(user: current_user, status: :draft))

    if @article.save
      render json: {
        article: BlogApp::ArticleSerializer.render_as_json(authorize(@article), current_user: current_user)
      }, status: :ok
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  # PUT /articles/:id
  def update
    if @article.update(article_params)
      render json: {
        article: BlogApp::ArticleSerializer.render_as_json(authorize(@article), current_user: current_user)
      }, status: :ok
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end


  # DELETE /articles/:id/destroy_permanently
  def destroy_permanently
    if authorize(@article).delete
      render json: {
        article: BlogApp::ArticleSerializer.render_as_json(authorize(@article), current_user: current_user)
      }, status: :ok
    else
      render_unprocessable_entity(@article)
    end
  end

  # DELETE /articles/:id/restore
  def restore
    if authorize(@article).update(status: :published, deleted_at: nil)
      render json: {
        article: BlogApp::ArticleSerializer.render_as_json(authorize(@article), current_user: current_user)
      }, status: :ok
    else
      render_unprocessable_entity(@article)
    end
  end

  # DELETE /articles/:id
  def destroy
    if authorize(@article).update(status: :trashed, deleted_at: Time.now)

      render json: {
        article: BlogApp::ArticleSerializer.render_as_json(authorize(@article), current_user: current_user)
      }, status: :ok
    else
      render_unprocessable_entity(@article)
    end
  end

  private

  def record_view(viewable, user: nil, ip_address: nil, user_agent: nil)
    # Only create a view if it doesn’t already exist for this user or guest
    View.find_or_create_by(
      viewable: viewable,
      user: user,
      ip_address: user ? nil : ip_address,
      user_agent: user ? nil : user_agent
    )
  end

  def article_index(articles, status)
    articles = articles.search_articles(params[:search]) if params[:search].present?

    paginate_render(
      BlogApp::ArticleSerializer,
      status === :published ? articles.order(updated_at: :desc) : policy_scope(articles.order(updated_at: :desc)),
      extra: {
        root: :articles,
        current_user: current_user
      }
    )
  end

  def set_article
    @article = BlogApp::Article.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Article not found' }, status: :not_found
  end

  def article_params
    params.permit(:title, :description, :status, :cover_photo, :published_at, :user_id, :subtitle, :duration)
  end
end
