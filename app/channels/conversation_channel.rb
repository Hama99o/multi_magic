class ConversationChannel < ApplicationCable::Channel
  def subscribed
    # Fetch the conversation
    @conversation = Conversation.find_by(id: params[:conversation_id])

    # Reject the subscription if no conversation is found
    return reject_subscription if @conversation.nil?

    current_user.update_sign_in_tracking!
    stream_for @conversation
  end

  def update(data)
    # Ensure @conversation is set
    return reject_subscription if @conversation.nil?

    # Create a new message for this conversation
    @message = @conversation.messages.build(body: data['message'], user: current_user)

    if @message.save
      @conversation.update(updated_at: Time.current)
      @conversation.conversation_members.reload.each(&:restore!)
      # Broadcast the new message to all subscribers
      ConversationChannel.broadcast_to(@conversation, MessageSerializer.render_as_json(@message, user: current_user))
    else
      transmit(errors: @message.errors.full_messages)
    end
  end

  # Handle the typing event
  def typing
    current_user.update_sign_in_tracking!
    ConversationChannel.broadcast_to(@conversation, { typing: true, user: current_user })
  end

  # New method to mark messages as seen
  def mark_read_at(data)
    unseen_message = Message.where.not(user_id: current_user.id).find_by(read_at: nil, id: data['message_id'])

    if unseen_message
      unseen_message.update(read_at: Time.current)
      ConversationChannel.broadcast_to(@conversation, { mark_read_at: true, message: MessageSerializer.render_as_json(unseen_message, user: current_user) })
    end
  end

  def unsubscribed
    # Cleanup any resources when the channel is unsubscribed
  end
end
