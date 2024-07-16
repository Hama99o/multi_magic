# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/note
class NotePreview < ActionMailer::Preview
  def share_note
    NoteMailer.share_note(NoteApp::Note.last, User.first)
  end

  def send_reminder
    NoteMailer.send_reminder(NoteApp::Note.last, User.first)
  end
end
