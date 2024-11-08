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
require 'rails_helper'

RSpec.describe Conversation, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
