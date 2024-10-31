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
class MessageSerializer < ApplicationSerializer
  identifier :id
  fields :conversation_id, :user_id, :body, :read_at, :created_at

  field :sent_by_me do |message, options|
    options[:user] == message.user
  end
end
