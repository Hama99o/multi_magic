class Api::V1::Conversations::MessagesController < ApplicationController
  before_action :set_conversation

  def index
    if @conversation.recipient == current_user
      @messages = policy_scope(@conversation.messages.where(recipient_deleted_at: nil).order(created_at: :desc))
    elsif @conversation.sender == current_user
      @messages = policy_scope(@conversation.messages.where(sender_deleted_at: nil).order(created_at: :desc))
    end

    paginate_render(
      MessageSerializer,
      @messages,
      per_page: 15,
      extra: {
        user: current_user
      }
    )
  end

  def create
    @message = @conversation.messages.build(message_params.merge(user: current_user))
    authorize @message
    if @message.save
      render json: @message
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @message = Message.find(params[:id])
    @message.soft_delete(current_user)
    render json: { message: "Message deleted for you." }, status: :ok
  end

  def destroy_permanently
    @message = Message.find(params[:id])
    @message.destroy
    render json: { message: "Message deleted for you." }, status: :ok
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
    authorize @conversation, :show?
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
