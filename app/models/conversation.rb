# == Schema Information
#
# Table name: conversations
#
#  id                   :bigint           not null, primary key
#  sender_id            :integer
#  recipient_id         :integer
#  sender_deleted_at    :datetime
#  recipient_deleted_at :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  is_ai                :boolean          default(FALSE)
#
class Conversation < ApplicationRecord
  # Associations
  belongs_to :sender, foreign_key: :sender_id, class_name: 'User'
  belongs_to :recipient, foreign_key: :recipient_id, class_name: 'User'
  has_many :messages, dependent: :destroy

  # Ensure sender_id is always less than recipient_id
  before_validation :normalize_user_ids

  # Custom validation to ensure uniqueness of conversation
  validate :conversation_uniqueness, on: [:create]  # Only on create or update


  include PgSearch::Model

  pg_search_scope :search_conversations,
                  against: [],
                  associated_against: {
                    recipient: %i[lastname firstname],
                    sender: %i[lastname firstname],
                  },
                  using: {
                    tsearch: { prefix: true }
                  }
  # Scopes
  scope :between, -> (user1_id, user2_id) do
    where(sender_id: [user1_id, user2_id], recipient_id: [user1_id, user2_id])
  end

  scope :involving, ->(user) {
    where(sender_id: user.id).or(where(recipient_id: user.id))
      .where.not("(sender_id = ? AND sender_deleted_at IS NOT NULL) OR (recipient_id = ? AND recipient_deleted_at IS NOT NULL)", user.id, user.id)
  }

  # Custom logic to handle soft delete
  def soft_delete(user)
    if user.id == sender_id && user.id == recipient_id
      return destroy
    end
    if user.id == sender_id
      if recipient_deleted_at.present?  # If recipient already deleted it
        destroy                         # Permanently delete conversation
      else
        update(sender_deleted_at: Time.current)  # Soft delete for sender
        messages.update_all(sender_deleted_at: Time.current)  # Soft delete for sender
      end
    elsif user.id == recipient_id
      if sender_deleted_at.present?  # If sender already deleted it
        destroy                      # Permanently delete conversation
      else
        update(recipient_deleted_at: Time.current)  # Soft delete for recipient
        messages.update_all(recipient_deleted_at: Time.current)  # Soft delete for sender
      end
    end
  end

  def is_self_conversation
    sender_id == recipient_id
  end

  # Check if conversation is deleted for a user
  def deleted_for?(user)
    (user.id == sender_id && sender_deleted_at.present?) || (user.id == recipient_id && recipient_deleted_at.present?)
  end

  def recreate!
    update(recipient_deleted_at: nil, sender_deleted_at: nil)
  end

  def self.get_unread_messages_by_user(user)
    conversations = Conversation.involving(user)
    conversations_count = Conversation.where(id: conversations.ids).joins(:messages).where.not(messages: { user_id: user.id }).where(messages: { read_at: nil, sender_deleted_at: nil, recipient_deleted_at: nil })&.distinct&.count
    conversations_count
  end

  private

  # Ensure that sender_id is always smaller than recipient_id
  def normalize_user_ids
    if sender_id > recipient_id
      self.sender_id, self.recipient_id = recipient_id, sender_id
    end
  end

  # Custom validation to check for uniqueness of conversation regardless of sender/recipient order
  def conversation_uniqueness
    if Conversation.exists?(sender_id: sender_id, recipient_id: recipient_id) ||
        Conversation.exists?(sender_id: recipient_id, recipient_id: sender_id)
      errors.add(:base, "Conversation between these users already exists")
    end
  end
end
