# frozen_string_literal: true

# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  conversation_id :integer          not null
#  user_id         :integer          not null
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

require 'rails_helper'

RSpec.describe Message, type: :model do
  subject(:message) { build(:message, conversation: create(:conversation), user: create(:user)) }

  describe 'associations' do
    it { is_expected.to belong_to(:conversation) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:message_reads).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:body) }
  end

  describe 'scopes' do
    let(:conversation) { create(:conversation) }
    let(:other_conversation) { create(:conversation) }
    let!(:msg_in) { create(:message, conversation: conversation, user: create(:user)) }
    let!(:msg_out) { create(:message, conversation: other_conversation, user: create(:user)) }

    describe '.for_conversation' do
      it 'returns messages for the given conversation' do
        expect(described_class.for_conversation(conversation.id)).to include(msg_in)
        expect(described_class.for_conversation(conversation.id)).not_to include(msg_out)
      end
    end
  end

  describe '#visible_to?' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:conversation) { create(:conversation) }
    let(:msg) { create(:message, conversation: conversation, user: user) }

    before { create(:conversation_member, conversation: conversation, user: user, deleted_at: nil) }

    it 'returns true when the user is an active member of the conversation' do
      expect(msg.visible_to?(user)).to be true
    end

    it 'returns false when the user is not in the conversation' do
      expect(msg.visible_to?(other_user)).to be false
    end
  end
end
