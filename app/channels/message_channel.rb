# app/channels/message_channel.rb
class MessageChannel < ApplicationCable::Channel
  def subscribed
    # Subscribe to a specific conversation based on the `conversation_id`
    stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
