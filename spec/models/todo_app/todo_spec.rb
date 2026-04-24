# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TodoApp::Todo, type: :model do
  subject(:todo) { build(:todo, user: user, todo_group: todo_group) }

  let(:user) { create(:user) }
  let(:todo_group) { create(:todo_group, user: user) }

  describe 'associations' do
    it { is_expected.to belong_to(:todo_group).class_name('TodoApp::TodoGroup') }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe 'scopes' do
    let!(:active_todo)    { create(:todo, user: user, todo_group: todo_group, deleted_at: nil) }
    let!(:deleted_todo)   { create(:todo, user: user, todo_group: todo_group, deleted_at: 1.day.ago) }
    let!(:completed_todo) { create(:todo, user: user, todo_group: todo_group, completed: true, deleted_at: nil) }
    let!(:pending_todo)   { create(:todo, user: user, todo_group: todo_group, completed: false, deleted_at: nil) }

    it '.active returns only todos without deleted_at' do
      expect(described_class.active).to include(active_todo, completed_todo, pending_todo)
      expect(described_class.active).not_to include(deleted_todo)
    end

    it '.completed returns only completed todos' do
      expect(described_class.completed).to include(completed_todo)
      expect(described_class.completed).not_to include(pending_todo)
    end

    it '.pending returns only incomplete todos' do
      expect(described_class.pending).to include(pending_todo)
      expect(described_class.pending).not_to include(completed_todo)
    end
  end

  describe 'acts_as_list' do
    it 'sets position automatically on create' do
      t1 = create(:todo, user: user, todo_group: todo_group)
      t2 = create(:todo, user: user, todo_group: todo_group)
      expect(t1.position).to be < t2.position
    end
  end
end
