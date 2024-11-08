class Api::V1::Conversations::MessagesController < ApplicationController
  before_action :set_conversation
  before_action :set_message, only: [:destroy, :destroy_permanently]

  def index
    # Retrieve only messages visible to the current user
    @messages = policy_scope(@conversation.messages.visible_for(current_user).order(created_at: :desc))

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
    # Build a new message within the conversation and set the current user as sender
    @message = @conversation.messages.build(message_params.merge(user: current_user))
    authorize @message

    if @message.save
      render json: MessageSerializer.render_as_json(@message, user: current_user), status: :created
    else
      render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    # Soft delete the message for the current user
    @message.soft_delete_for(current_user)
    render json: { message: "Message deleted for you." }, status: :ok
  end

  def destroy_permanently
    # Permanently delete the message
    @message.destroy
    render json: { message: "Message permanently deleted." }, status: :ok
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
    authorize @conversation, :show?
  end

  def set_message
    @message = @conversation.messages.find(params[:id])
    authorize @message
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
