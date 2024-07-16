# == Schema Information
#
# Table name: messages
#
#  id                   :bigint           not null, primary key
#  conversation_id      :bigint           not null
#  user_id              :bigint           not null
#  body                 :text
#  read_at              :datetime
#  sender_deleted_at    :datetime
#  recipient_deleted_at :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  role                 :string
#
# Indexes
#
#  index_messages_on_conversation_id  (conversation_id)
#  index_messages_on_user_id          (user_id)
#
class Message < ApplicationRecord
  # Associations
  belongs_to :conversation
  belongs_to :user

  # Validations
  validates :body, presence: true

  # Scopes for retrieving messages
  scope :for_conversation, -> (conversation_id) { where(conversation_id: conversation_id) }

  # Custom logic to handle soft delete
  def soft_delete(user)
    if user.id == conversation.sender_id
      if recipient_deleted_at.present?  # If recipient already deleted it
        destroy                         # Permanently delete message
      else
        update(sender_deleted_at: Time.current)  # Soft delete for sender
      end
    elsif user.id == conversation.recipient_id
      if sender_deleted_at.present?  # If sender already deleted it
        destroy                      # Permanently delete message
      else
        update(recipient_deleted_at: Time.current)  # Soft delete for recipient
      end
    end
  end

  # Check if message is deleted for a user
  def deleted_for?(user)
    (user.id == conversation.sender_id && sender_deleted_at.present?) || (user.id == conversation.recipient_id && recipient_deleted_at.present?)
  end

  # Scope to retrieve messages that are not deleted for a user
  scope :visible_for, ->(user) {
    where.not("(user_id = ? AND sender_deleted_at IS NOT NULL) OR (user_id = ? AND recipient_deleted_at IS NOT NULL)", user.id, user.id)
  }

  after_create_commit { broadcast_message }

  private

  def broadcast_message
    # This will broadcast the message to the subscribed channel
    recipient = conversation.recipient
    sender = conversation.sender
    user_to_inform = user.id === sender.id ? recipient : sender
    MessageChannel.broadcast_to(sender, {
      message: MessageSerializer.render_as_json(self, user: sender), # Use a serializer for the message
      conversation: ConversationSerializer.render_as_json(self.conversation, user: sender)
    })

    return if sender.id === recipient.id
    MessageChannel.broadcast_to(recipient, {
      message: MessageSerializer.render_as_json(self, user: recipient), # Use a serializer for the message
      conversation: ConversationSerializer.render_as_json(self.conversation, user: recipient)
    })
  end
end
