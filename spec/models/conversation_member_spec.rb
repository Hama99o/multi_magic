# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConversationMember, type: :model do
  subject(:member) { build(:conversation_member) }

  describe 'associations' do
    it { is_expected.to belong_to(:conversation) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(active: 0, trashed: 1) }
  end

  describe 'scopes' do
    let(:conversation) { create(:conversation) }
    let!(:admin_member) do
      create(:conversation_member, conversation: conversation, is_admin: true)
    end
    let!(:regular_member) do
      create(:conversation_member, conversation: conversation, is_admin: false)
    end

    describe '.admins' do
      it 'returns only admin members' do
        expect(described_class.admins).to include(admin_member)
        expect(described_class.admins).not_to include(regular_member)
      end
    end

    describe '.active_members' do
      let!(:trashed_member) do
        create(:conversation_member, conversation: conversation, status: :trashed)
      end

      it 'returns only active members' do
        expect(described_class.active_members).to include(regular_member)
        expect(described_class.active_members).not_to include(trashed_member)
      end
    end
  end

  describe '#soft_delete!' do
    let(:cm) { create(:conversation_member) }

    it 'sets deleted_at' do
      cm.soft_delete!
      expect(cm.reload.deleted_at).not_to be_nil
    end

    it 'sets status to trashed' do
      cm.soft_delete!
      expect(cm.reload.status).to eq('trashed')
    end
  end

  describe '#restore!' do
    let(:cm) { create(:conversation_member, status: :trashed, deleted_at: Time.current) }

    it 'clears deleted_at' do
      cm.restore!
      expect(cm.reload.deleted_at).to be_nil
    end

    it 'sets status to active' do
      cm.restore!
      expect(cm.reload.status).to eq('active')
    end
  end

  describe '#admin?' do
    it 'returns true when is_admin is true' do
      member.is_admin = true
      expect(member.admin?).to be true
    end

    it 'returns false when is_admin is false' do
      member.is_admin = false
      expect(member.admin?).to be false
    end
  end
end
