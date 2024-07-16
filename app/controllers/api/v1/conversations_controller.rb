class Api::V1::ConversationsController < ApplicationController
  def index
    @conversations = policy_scope(Conversation.order(updated_at: :desc))
    @conversations = @conversations.search_conversations(params[:search]) if params[:search].present?

    paginate_render(
      ConversationSerializer,
      @conversations,
      per_page: 15,
      extra: {
        user: current_user
      }
    )
  end

  def unread_messages_count
    render json: { unread_messages_count: Conversation.get_unread_messages_by_user(current_user) }
  end

  def create
    # Normalize sender_id and recipient_id order
    if current_user.id == params[:user_id].to_i
      @conversation = Conversation.where(sender_id: current_user.id, recipient_id: current_user.id).between(current_user.id, params[:user_id]).first
      if !@conversation
        @conversation = Conversation.where(recipient_id: current_user.id, sender_id: current_user.id).between(current_user.id, params[:user_id]).first
      end
    else
      @conversation = Conversation.between(current_user.id, params[:user_id]).where.not(recipient_id: current_user.id, sender_id: current_user.id).first
    end

    if @conversation
      # Restore soft-deleted conversations
      if current_user.id == @conversation.sender_id && @conversation.sender_deleted_at
        @conversation.update!(sender_deleted_at: nil)
      elsif current_user.id == @conversation.recipient_id && @conversation.recipient_deleted_at
        @conversation.update!(recipient_deleted_at: nil)
      end
      render json: { conversation: ConversationSerializer.render_as_json(@conversation, user: current_user) }
    else
      # If no conversation exists, create a new one
      @conversation = Conversation.new(sender_id: current_user.id, recipient_id: params[:user_id])

      if @conversation.save
        authorize @conversation
        render json: { conversation: ConversationSerializer.render_as_json(@conversation, user: current_user) }
      else
        render json: { errors: @conversation.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def show
    @conversation = Conversation.find(params[:id])
    authorize @conversation
    if current_user.id == @conversation.sender_id && !@conversation.sender_deleted_at
      render json: { conversation: ConversationSerializer.render_as_json(@conversation, user: current_user) }
    elsif current_user.id == @conversation.recipient_id && !@conversation.recipient_deleted_at
      render json: { conversation: ConversationSerializer.render_as_json(@conversation, user: current_user) }
    else
      render json: { message: "no conversation found." }, status: :ok
    end
  end

  def destroy
    @conversation = Conversation.find(params[:id])
    @conversation.soft_delete(current_user)
    render json: { message: "Conversation deleted for you." }, status: :ok
  end

  private

  def conversation_params
    params.permit(:sender_id, :recipient_id)
  end
end

