class Api::V1::ConversationsController < ApplicationController
  before_action :set_conversation, only: %i[show destroy]

  # List all conversations for the current user, with search and pagination
  def index
    # Fetch conversations involving the current user, ordered by last update
    @conversations = Conversation.joins(:conversation_members)
                                 .where(conversation_members: { user_id: current_user.id, deleted_at: nil })
                                 .order(updated_at: :desc)

    # Apply search if a search term is present
    @conversations = @conversations.search_conversations(params[:search]) if params[:search].present?

    # Paginate and render
    paginate_render(
      ConversationSerializer,
      @conversations,
      per_page: 15,
      extra: {
        user: current_user
      }
    )
  end

  # Get the count of unread messages for the current user
  def unread_messages_count
    render json: { unread_messages_count: Conversation.get_unread_messages_by_user(current_user) }
  end

  # Create a conversation, one-to-one or group
  def create
    # Check if conversation already exists (for one-to-one)
    if params[:user_id] && current_user.id != params[:user_id].to_i
      @conversation = Conversation.find_one_to_one(current_user.id, params[:user_id])
      if @conversation
        @conversation.update(updated_at: Time.now)
        # Restore if soft-deleted for this user
        @conversation.restore_for_user(current_user)
        render json: { conversation: ConversationSerializer.render_as_json(@conversation, user: current_user) }
        return
      end

    elsif params[:user_id] && current_user.id == params[:user_id].to_i
      @conversation = Conversation.find_single(params[:user_id])
      if @conversation
        @conversation.update(updated_at: Time.now)
        # Restore if soft-deleted for this user
        @conversation.restore_for_user(current_user)
        render json: { conversation: ConversationSerializer.render_as_json(@conversation, user: current_user) }
        return
      end
    end

    # If no existing conversation, create a new one (one-to-one or group)
    @conversation = if params[:user_id]
                      Conversation.create_one_to_one(current_user.id, params[:user_id])
                    else
                      Conversation.create_group(params[:name], current_user, params[:user_ids])
                    end

    if @conversation.persisted?
      render json: { conversation: ConversationSerializer.render_as_json(@conversation, user: current_user) }
    else
      render json: { errors: @conversation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Show a specific conversation, if the current user is a participant
  def show
    if @conversation_member
      render json: { conversation: ConversationSerializer.render_as_json(@conversation, user: current_user) }
    else
      render json: { message: "Conversation not found or deleted for you." }, status: :not_found
    end
  end

  # Soft-delete a conversation for the current user
  def destroy
    if @conversation_member
      @conversation.soft_delete_for_user(current_user)

      render json: { message: "Conversation deleted for you." }, status: :ok
    else
      render json: { message: "Conversation not found." }, status: :not_found
    end
  end

  private

  # Set conversation and check if the current user is a member
  def set_conversation
    @conversation = Conversation.find_by(id: params[:id])
    @conversation_member = @conversation&.conversation_members&.find_by(user_id: current_user.id, deleted_at: nil)
  end
end
