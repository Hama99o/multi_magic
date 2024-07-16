class Api::V1::BlogApp::TagsController < ApplicationController
  before_action :set_tag, only: [:show, :update, :destroy]
  skip_before_action :authenticate_user!, only: [:index]

  # GET /tags
  def index
    tags = BlogApp::Tag.all
    tags = tags.search_tags(params[:search]) if params[:search].present?

    paginate_render(
      TagSerializer,
      tags.order(:updated_at),
      per_page: 50,
      extra: {
        root: :tags,
        current_user: current_user
      }
    )
  end

  def create
    tag = BlogApp::Tag.new(tag_params.merge(user_id: current_user.id))

    if tag.save
      render json: {
        tag: TagSerializer.render_as_json(tag, current_user: current_user)
      }, status: :ok
    else
      render json: tag.errors, status: :unprocessable_entity
    end
  end

  def update
    if @tag.update(tag_params)
      render json: { tag: TagSerializer.render_as_json(@tag, current_user: current_user) }
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tags/:id
  def destroy
    if @tag&.destroy
      render json: { tag: @tag }, status: :ok
    else
      render_unprocessable_entity(@tag)
    end
  end

  private

  # Find tag by ID
  def set_tag
    @tag = BlogApp::Tag.find(params[:id])
  end

  # Only allow a list of trusted parameters through
  def tag_params
    params.require(:tag).permit(:name)
  end
end
