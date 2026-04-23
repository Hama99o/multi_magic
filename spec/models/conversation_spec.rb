# frozen_string_literal: true

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
  subject(:conversation) { build(:conversation) }

  describe 'associations' do
    it { is_expected.to have_many(:messages).dependent(:destroy) }
    it { is_expected.to have_many(:conversation_members).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:conversation_members) }
  end

  describe 'scopes' do
    let!(:direct_conv) { create(:conversation, is_group: false) }
    let!(:group_conv)  { create(:conversation, is_group: true) }

    describe '.direct' do
      it 'returns only non-group conversations' do
        expect(described_class.direct).to include(direct_conv)
        expect(described_class.direct).not_to include(group_conv)
      end
    end

    describe '.groups' do
      it 'returns only group conversations' do
        expect(described_class.groups).to include(group_conv)
        expect(described_class.groups).not_to include(direct_conv)
      end
    end
  end

  describe '#is_self_conversation?' do
    let(:user) { create(:user) }
    let(:conv) { create(:conversation) }

    it 'returns true when only one user is in the conversation' do
      create(:conversation_member, conversation: conv, user: user)
      expect(conv.is_self_conversation?).to be true
    end

    it 'returns false when more than one user is in the conversation' do
      create(:conversation_member, conversation: conv, user: user)
      create(:conversation_member, conversation: conv, user: create(:user))
      expect(conv.is_self_conversation?).to be false
    end
  end

  describe '#includes_user?' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:conv) { create(:conversation) }

    before { create(:conversation_member, conversation: conv, user: user) }

    it 'returns true when the user is a member' do
      expect(conv.includes_user?(user)).to be true
    end

    it 'returns false when the user is not a member' do
      expect(conv.includes_user?(other_user)).to be false
    end
  end

  describe '#soft_delete_for_user' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:conv) { create(:conversation) }
    let!(:member) { create(:conversation_member, conversation: conv, user: user) }
    let!(:other_member) { create(:conversation_member, conversation: conv, user: other_user) }

    it 'soft-deletes the member record' do
      conv.soft_delete_for_user(user)
      expect(member.reload.deleted_at).not_to be_nil
    end

    it 'sets the member status to trashed' do
      conv.soft_delete_for_user(user)
      expect(member.reload.status).to eq('trashed')
    end
  end
end
