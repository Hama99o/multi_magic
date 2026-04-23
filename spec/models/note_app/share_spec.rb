# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NoteApp::Share, type: :model do
  subject(:share) do
    build(:note_app_share, note: note, shared_with_user: shared_user, role: :viewer)
  end

  let(:owner) { create(:user) }
  let(:shared_user) { create(:user) }
  let(:note) { create(:note, owner: owner) }

  describe 'associations' do
    it { is_expected.to belong_to(:note).class_name('NoteApp::Note') }
    it { is_expected.to belong_to(:shared_with_user).class_name('User') }
  end

  describe 'enums' do
    it {
      expect(subject).to define_enum_for(:role)
        .with_values(viewer: 0, contributor: 1, administrator: 2)
    }
  end

  describe 'creation' do
    it 'is valid with required attributes' do
      expect(share).to be_valid
    end

    it 'defaults to viewer role' do
      new_share = build(:note_app_share, note: note, shared_with_user: shared_user)
      expect(new_share.role).to eq('viewer')
    end
  end
end
