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
class ConversationSerializer < ApplicationSerializer
  identifier :id
  fields :sender_id, :recipient_id, :created_at

  field :name do |conversation, options|
    if options[:user] == conversation&.recipient
      conversation&.sender&.fullname&.presence
    else
      conversation&.recipient&.fullname&.presence
    end
  end

  field :user do |conversation, options|
    if options[:user] == conversation&.recipient
      UserSerializer.render_as_hash(conversation&.sender, view: :private)
    else
      UserSerializer.render_as_hash(conversation&.recipient, view: :private)
    end
  end

  field :last_message do |conversation, options|
    next if conversation.messages.blank?
    MessageSerializer.render_as_hash(conversation.messages.order(:created_at).last, user: options[:user])
  end
end
