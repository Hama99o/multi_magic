# == Schema Information
#
# Table name: messages
#
#  id              :bigint           not null, primary key
#  conversation_id :bigint           not null
#  user_id         :bigint           not null
#  body            :text
#  read_at         :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  role            :string
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

  # Scopes
  scope :for_conversation, ->(conversation_id) { where(conversation_id: conversation_id) }

  # Mark a message as read for a specific user
  def mark_as_read_for(user)
    participant = conversation.conversation_members.find_by(user_id: user.id)
    participant.update!(last_read_at: Time.current) if participant
  end

  # Checks if the message is visible to a given user (not deleted for them)
  def visible_to?(user)
    conversation.conversation_members.where(user_id: user.id, deleted_at: nil).exists?
  end

  # Scope for messages visible to a specific user
  scope :visible_for, ->(user) {
    joins(:conversation)
      .joins("INNER JOIN conversation_members ON conversation_members.conversation_id = messages.conversation_id")
      .where(conversation_members: { user_id: user.id, status: 0 }) ## 0 is active status
      .where("messages.created_at > COALESCE(conversation_members.soft_deleted_at, '1970-01-01')")
      .distinct
  }

  # Broadcast message after creation to all participants in the conversation
  after_create_commit :broadcast_message

  private

  # Broadcast the message to all participants in the conversation
  def broadcast_message
    conversation.conversation_members.each do |member|
      MessageChannel.broadcast_to(
        member.user,
        message: MessageSerializer.render_as_json(self, user: member.user),
        conversation: ConversationSerializer.render_as_json(conversation, user: member.user)
      )
    end
  end
end
