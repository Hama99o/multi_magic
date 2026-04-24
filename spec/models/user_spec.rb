# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:firstname) }
    it { is_expected.to validate_presence_of(:lastname) }
    it { is_expected.to validate_uniqueness_of(:username).case_insensitive }

    it 'validates username format (alphanumeric only)' do
      user.username = 'valid123'
      expect(user).to be_valid

      user.username = 'invalid-username!'
      expect(user).not_to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to have_many(:notes).class_name('NoteApp::Note') }
    it { is_expected.to have_many(:expenses).class_name('MyFinanceApp::Expense') }
    it { is_expected.to have_many(:loans).class_name('MyFinanceApp::Loan') }
    it { is_expected.to have_many(:contacts).class_name('ContactApp::Contact') }
    it { is_expected.to have_many(:articles).class_name('BlogApp::Article') }
    it { is_expected.to have_many(:conversation_members).dependent(:destroy) }
    it { is_expected.to have_many(:conversations).through(:conversation_members) }
    it { is_expected.to have_many(:messages).dependent(:destroy) }
    it { is_expected.to have_many(:message_reads).dependent(:destroy) }
    it { is_expected.to have_many(:comments).dependent(:destroy) }
    it { is_expected.to have_many(:reactions).dependent(:destroy) }
    it { is_expected.to have_many(:bookmarks).dependent(:destroy) }
    it { is_expected.to have_many(:views).dependent(:destroy) }
    it { is_expected.to have_many(:active_follows).class_name('Follow') }
    it { is_expected.to have_many(:following).through(:active_follows) }
    it { is_expected.to have_many(:passive_follows).class_name('Follow') }
    it { is_expected.to have_many(:followers).through(:passive_follows) }
    it { is_expected.to have_many(:active_blocks).class_name('Block') }
    it { is_expected.to have_many(:passive_blocks).class_name('Block') }
    it { is_expected.to have_many(:todo_groups).class_name('TodoApp::TodoGroup').dependent(:destroy) }
    it { is_expected.to have_many(:todos).class_name('TodoApp::Todo').dependent(:destroy) }
    it { is_expected.to have_many(:tags).dependent(:destroy) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:access_level).with_values(employee: 0, admin: 1, super_admin: 2) }
    it { is_expected.to define_enum_for(:status).with_values(inactive: 0, active: 1) }
  end

  describe '#fullname' do
    it 'returns titleized firstname and upcased lastname' do
      user.firstname = 'john'
      user.lastname = 'doe'
      expect(user.fullname).to eq('John DOE')
    end
  end

  describe '#admin_or_above?' do
    it 'returns true for admin' do
      user.access_level = :admin
      expect(user.admin_or_above?).to be true
    end

    it 'returns true for super_admin' do
      user.access_level = :super_admin
      expect(user.admin_or_above?).to be true
    end

    it 'returns false for employee' do
      user.access_level = :employee
      expect(user.admin_or_above?).to be false
    end
  end

  describe '#follow / #unfollow / #following?' do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }

    it 'allows a user to follow another user' do
      user_a.follow(user_b)
      expect(user_a.following?(user_b)).to be true
    end

    it 'does not allow a user to follow themselves' do
      user_a.follow(user_a)
      expect(user_a.following?(user_a)).to be false
    end

    it 'allows a user to unfollow another user' do
      user_a.follow(user_b)
      user_a.unfollow(user_b)
      expect(user_a.following?(user_b)).to be false
    end

    it 'does not follow a user that is blocked' do
      user_a.block(user_b)
      user_a.follow(user_b)
      expect(user_a.following?(user_b)).to be false
    end
  end

  describe '#block / #unblock / #blocking?' do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }

    it 'allows a user to block another user' do
      user_a.block(user_b)
      expect(user_a.blocking?(user_b)).to be true
    end

    it 'does not allow a user to block themselves' do
      user_a.block(user_a)
      expect(user_a.blocking?(user_a)).to be false
    end

    it 'allows a user to unblock another user' do
      user_a.block(user_b)
      user_a.unblock(user_b)
      expect(user_a.blocking?(user_b)).to be false
    end
  end

  describe '#all_notes' do
    let(:owner) { create(:user) }
    let(:shared_user) { create(:user) }
    let!(:owned_note) { create(:note, owner: owner) }
    let!(:shared_note) { create(:note) }

    before do
      create(:note_app_share, note: shared_note, shared_with_user: owner)
    end

    it 'returns owned and shared notes' do
      result = owner.all_notes
      expect(result).to include(owned_note, shared_note)
    end
  end

  describe 'before_validation :generate_unique_username' do
    it 'auto-generates a username from firstname and lastname on create' do
      u = build(:user, firstname: 'Alice', lastname: 'Smith')
      u.username = nil
      u.valid?
      expect(u.username).to be_present
      expect(u.username).to match(/\A[a-zA-Z0-9]+\z/)
    end
  end

  describe 'before_create :set_default_value_of_data' do
    it 'sets default note_index_type to card_list' do
      u = create(:user)
      expect(u.note_index_type).to eq('card_list')
    end

    it 'sets default theme to dark' do
      u = create(:user)
      expect(u.theme).to eq('dark')
    end
  end

  describe '#update_sign_in_tracking!' do
    let(:tracked_user) { create(:user) }

    it 'increments sign_in_count' do
      expect { tracked_user.update_sign_in_tracking! }
        .to change { tracked_user.reload.sign_in_count }.by(1)
    end

    it 'sets current_sign_in_at' do
      tracked_user.update_sign_in_tracking!
      expect(tracked_user.reload.current_sign_in_at).to be_within(5.seconds).of(Time.current)
    end
  end
end
