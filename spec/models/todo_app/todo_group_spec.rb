# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TodoApp::TodoGroup, type: :model do
  subject(:todo_group) { build(:todo_group, user: user) }

  let(:user) { create(:user) }

  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:todos).class_name('TodoApp::Todo').dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'scopes' do
    let!(:active_group)  { create(:todo_group, user: user, deleted_at: nil) }
    let!(:deleted_group) { create(:todo_group, user: user, deleted_at: 1.day.ago) }

    it '.active returns groups without deleted_at' do
      expect(described_class.active).to include(active_group)
      expect(described_class.active).not_to include(deleted_group)
    end
  end

  describe 'acts_as_list' do
    it 'sets position automatically on create' do
      g1 = create(:todo_group, user: user)
      g2 = create(:todo_group, user: user)
      expect(g1.position).to be < g2.position
    end
  end
end
