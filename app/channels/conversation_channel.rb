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

  def mark_read_at(data)
    message = Message.find_by(id: data['message_id'])

    # Return if message doesn't exist or belongs to the current user
    return unless message && message.user_id != current_user.id

    # Check if the current user has already marked the message as read
    message_read = MessageRead.find_or_initialize_by(user_id: current_user.id, message_id: message.id)

    if message_read.new_record?
      message_read.read_at = Time.current
      message_read.save

      # Check if all participants in the conversation have read the message
      participants_count = message.conversation.users.count - 1 # Exclude the sender
      reads_count = MessageRead.where(message_id: message.id).distinct.count(:user_id)

      # If all users have read the message, update the read_at timestamp on the message
      if reads_count >= participants_count
        message.update(read_at: Time.current)
      end

      # Broadcast the read status update to all participants in the conversation
      ConversationChannel.broadcast_to(message.conversation, {
        mark_read_at: true,
        message: MessageSerializer.render_as_json(message, user: current_user)
      })
    end
  end

  
  def unsubscribed
    # Cleanup any resources when the channel is unsubscribed
  end
end
