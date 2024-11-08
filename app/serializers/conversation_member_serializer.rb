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
class ConversationMemberSerializer < ApplicationSerializer
  identifier :id
  fields :conversation_id, :last_read_at, :is_admin

  # Include user details
  field :user do |conversation_member, options|
    UserSerializer.render_as_hash(conversation_member.user, view: :private)
  end

  # Field to check if the user has soft-deleted this conversation
  field :deleted do |conversation_member|
    conversation_member.deleted_at.present?
  end

  # Field to provide last read message (if implemented in Message model)
  field :last_message_read do |conversation_member, options|
    MessageSerializer.render_as_hash(
      conversation_member.conversation.messages.where('created_at <= ?', conversation_member.last_read_at).order(:created_at).last,
      user: options[:user]
    ) if conversation_member.last_read_at
  end
end
