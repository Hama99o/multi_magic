# == Schema Information
#
# Table name: message_reads
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  message_id :bigint           not null
#  read_at    :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_message_reads_on_message_id  (message_id)
#  index_message_reads_on_user_id     (user_id)
#
class MessageRead < ApplicationRecord
  belongs_to :user
  belongs_to :message
end
