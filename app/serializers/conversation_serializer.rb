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
class ConversationSerializer < ApplicationSerializer
  identifier :id
  fields :created_at, :title, :is_group

  field :can_delete do |conversation, options|
    next true unless conversation.is_group
    admin_user_ids = conversation.conversation_members.active.where(is_admin: true).pluck(:user_id)
    admin_user_ids.include?(options[:user]&.id)
  end

  # Dynamic conversation name based on participants (useful for one-to-one chats or unnamed groups)
  field :user do |conversation, options|
    if conversation.is_group
      { fullname: conversation.title.presence || "Group Conversation" }
    else
      # Show the other participant's name in one-to-one conversations
      if  conversation.conversation_members.count == 1
        other_user = conversation.conversation_members.first&.user
      else
        other_user = conversation.conversation_members.where.not(user_id: options[:user]&.id)&.first&.user
      end
      UserSerializer.render_as_hash(other_user, view: :private, current_user: options[:user])
    end
  end

  # Include an array of participants with user information
  field :participants do |conversation, options|
    conversation.conversation_members.active.map do |member|
      {
        user: UserSerializer.render_as_hash(member.user, view: :private, current_user: options[:user]),
        is_admin: member.is_admin,
        last_read_at: member.last_read_at
      }
    end
  end

  # Last message in the conversation
  field :last_message do |conversation, options|
    last_message = conversation.messages.visible_for(options[:user]).order(:created_at).last
    next unless last_message.present?
    MessageSerializer.render_as_hash(last_message, user: options[:user])
  end

  # Field for the unread messages count specific to the current user
  field :unread_messages_count do |conversation, options|
    # conversation.messages.where("created_at > ?", options[:user].last_read_at_for(conversation)).count
  end
end
