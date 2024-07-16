class Api::V1::NoteApp::TagsController < ApplicationController
  before_action :set_tag, only: [:show, :update, :destroy]

  # GET /tags
  def index
    tags = current_user.tags
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
    tag = NoteApp::Tag.new(tag_params.merge(user_id: current_user.id, position: NoteApp::Tag.last&.position || 1))

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
      if params[:tag] && params[:tag][:tag_ids]
        tag_ids = params[:tag][:tag_ids]&.map(&:to_i)

        current_user.tags.order(:position).each do |tag|
          if (tag_ids.include?(tag.id))
            tag.update!(position: tag_ids.find_index(tag.id) + 1)
          end
        end
      end

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
    @tag = current_user.tags.find_by(id: params[:id], user_id: current_user.id)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Tag not found' }, status: :not_found
  end

  # Only allow a list of trusted parameters through
  def tag_params
    params.require(:tag).permit(:name)
  end
end
