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
require 'rails_helper'

RSpec.describe Conversation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
