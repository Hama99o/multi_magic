# == Schema Information
#
# Table name: conversations
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  is_ai      :boolean          default(FALSE)
#  is_group   :boolean          default(FALSE), not null
#  title      :string
#
# Indexes
#
#  index_conversations_on_is_group  (is_group)
#
class Conversation < ApplicationRecord
  # Associations
  has_many :messages, dependent: :destroy
  has_many :conversation_members, dependent: :destroy
  has_many :users, through: :conversation_members

  # Scopes to differentiate between direct (one-to-one) and group conversations
  scope :direct, -> { where(is_group: false) }
  scope :groups, -> { where(is_group: true) }

  # Ensure the uniqueness of a direct conversation between two users
  # validate :ensure_unique_direct_conversation, if: -> { !is_group }

  # Search functionality
  include PgSearch::Model
  pg_search_scope :search_conversations,
                  against: :is_group,
                  associated_against: {
                    users: %i[lastname firstname]
                  },
                  using: {
                    tsearch: { prefix: true }
                  }

  # Check if the conversation is a self-conversation (where the user is both sender and recipient)
  def is_self_conversation?
    users.count == 1
  end

  # Check if the conversation includes a specific user
  def includes_user?(user)
    users.exists?(user.id)
  end

  # Soft delete a conversation for a user
  def soft_delete_for_user(user)
    member = conversation_members.find_by(user: user)
    if member
      member.soft_delete!
      cleanup_if_all_deleted
    end
  end

  # Find one-to-one conversation between two users
  def self.find_one_to_one(user_id1, user_id2)
    joins(:conversation_members)
      .where(is_group: false)
      .where(conversation_members: { user_id: [user_id1, user_id2] })
      .group('conversations.id')
      .having('COUNT(conversation_members.id) = 2')
      .first
  end

  # Find single conversation between two users
  def self.find_single(user_id1)
    joins(:conversation_members)
      .where(is_group: false)
      .where(conversation_members: { user_id: user_id1 })
      .where.not(id: Conversation.joins(:conversation_members)
        .where(is_group: false)
        .where.not(conversation_members: { user_id: user_id1 })
        .select(:id))
      .first
  end

  # Create a one-to-one conversation
  def self.create_one_to_one(user_id1, user_id2)
    # Check if a conversation already exists between these users
    existing_one_to_one_conversation = Conversation.joins(:conversation_members)
                                        .where(is_group: false)
                                        .where(conversation_members: { user_id: [user_id1, user_id2] })
                                        .group("conversations.id")
                                        .having("COUNT(conversation_members.id) = ?", user_id1 == user_id2 ? 1 : 2)
                                        .first

    return existing_one_to_one_conversation if existing_one_to_one_conversation

    # Transaction to ensure atomicity
    transaction do
      conversation = create!(is_group: false)
      # Only create a single conversation member if this is a self-conversation
      conversation.conversation_members.create!(user_id: user_id1)
      conversation.conversation_members.create!(user_id: user_id2) if user_id1.to_i != user_id2.to_i

      conversation
    end
  rescue ActiveRecord::RecordInvalid
    nil  # Return nil or handle failure as needed
  end

  # Create a group conversation
  def self.create_group(title, creator, user_ids)
    conversation = create!(is_group: true, title: title)
    conversation.conversation_members.create!(user_id: creator.id, is_admin: true)
    user_ids.each do |user_id|
      conversation.conversation_members.create!(user_id: user_id)
    end
    conversation
  end

  # Restore soft-deleted conversation for a user
  def restore_for_user(user)
    member = conversation_members.find_by(user_id: user.id)
    member&.restore!
  end

  # Check if the conversation is deleted for a user
  def deleted_for?(user)
    conversation_members.find_by(user: user)&.deleted?
  end

  # Get unread messages count for a specific user
  def self.get_unread_messages_by_user(user)
    Conversation.joins(:messages, :conversation_members)
                .where(conversation_members: { user_id: user.id, deleted_at: nil })
                .where("messages.created_at > COALESCE(conversation_members.soft_deleted_at, '1970-01-01')")
                .where(messages: { read_at: nil })
                .where.not(messages: { user_id: user.id })
                .distinct.count
  end

  private

  # Destroy the conversation if all members have soft-deleted it
  def cleanup_if_all_deleted
    if conversation_members.active.empty?
      destroy
    end
  end
end
