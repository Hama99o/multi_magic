# == Schema Information
#
# Table name: conversation_members
#
#  id              :bigint           not null, primary key
#  conversation_id :bigint           not null
#  user_id         :bigint           not null
#  status          :integer          default("active"), not null
#  last_read_at    :datetime
#  deleted_at      :datetime
#  soft_deleted_at :datetime
#  is_admin        :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_conversation_members_on_conversation_and_user  (conversation_id,user_id) UNIQUE
#  index_conversation_members_on_conversation_id        (conversation_id)
#  index_conversation_members_on_user_id                (user_id)
#
class ConversationMember < ApplicationRecord
  belongs_to :conversation
  belongs_to :user

  enum status: {
    active: 0,
    trashed: 1
  }
  # Optional: Scopes for convenience
  scope :admins, -> { where(is_admin: true) }
  scope :active, -> { where(deleted_at: nil) }

  # Scope to get all active members
  scope :active_members, -> { where(status: :active) }
  scope :trashed_members, -> { where(status: :trash) }

  # Soft delete method for user-specific deletion
  def soft_delete!
    update(deleted_at: Time.current, soft_deleted_at: Time.current, status: :trashed)
  end

  # Restore method - makes the conversation active for the user
  def restore!
    update(deleted_at: nil, status: :active)
  end

  # Check if the user is an admin in the conversation
  def admin?
    is_admin
  end
end
