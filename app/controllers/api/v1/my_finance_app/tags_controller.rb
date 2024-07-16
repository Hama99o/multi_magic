class Api::V1::MyFinanceApp::TagsController < ApplicationController
  before_action :set_tag, only: [:show, :update, :destroy]

  # GET /tags
  def index
    parent_id = params[:parent_id]
    # If parent_id is null, fetch parent categories; else, fetch subcategories
    tags = if parent_id.present?
              MyFinanceApp::Tag.where(user_id: current_user.id, parent_id: parent_id)
            else
              MyFinanceApp::Tag.where(user_id: current_user.id, parent_id: nil)
            end

    tags = tags.search_tags(params[:search]) if params[:search].present?

    paginate_render(
      TagSerializer,
      tags,
      per_page: 50,
      extra: {
        root: :tags,
        current_user: current_user
      }
    )
  end

  def create
    tag = MyFinanceApp::Tag.create(tag_params.merge(user_id: current_user.id))

    if tag
      render json: {
        tag: TagSerializer.render_as_json(tag, current_user: current_user)
      }, status: :ok
    else
      render json: { error: "Failed to create tag" }, status: :unprocessable_entity
    end
  end

  # DELETE /tags/:id
  def destroy
    if authorize(@tag).delete
      render json: { tag: @tag }, status: :ok
    else
      render_unprocessable_entity(@tag)
    end
  end

  private

  # Find tag by ID
  def set_tag
    @tag = MyFinanceApp::Tag.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Tag not found' }, status: :not_found
  end

  # Only allow a list of trusted parameters through
  def tag_params
    params.require(:tag).permit(:name, :parent_id)
  end
end
