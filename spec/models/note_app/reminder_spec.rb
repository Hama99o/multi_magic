# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NoteApp::Reminder, type: :model do
  subject(:reminder) do
    build(:note_app_reminder, user: user, note: note, reminder_time: 1.day.from_now)
  end

  let(:user) { create(:user) }
  let(:note) { create(:note, owner: user) }

  describe 'creation' do
    it 'is valid with required attributes' do
      expect(reminder).to be_valid
    end

    it 'defaults is_completed to false' do
      r = create(:note_app_reminder, user: user, note: note)
      expect(r.is_completed).to be false
    end

    it 'can be marked as completed' do
      r = create(:note_app_reminder, user: user, note: note)
      r.update!(is_completed: true)
      expect(r.reload.is_completed).to be true
    end
  end
end
