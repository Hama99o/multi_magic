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
FactoryBot.define do
  factory :message do
    conversation { nil }
    user { nil }
    body { "MyText" }
    read_at { "2024-09-04 17:27:28" }
  end
end
