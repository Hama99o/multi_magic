# app/workers/note_reminder_worker.rb
class NoteReminderWorker
  include Sidekiq::Worker

  def perform(note_id, user_id)
    note = NoteApp::Note.find(note_id)
    user = User.find(user_id)

    # Send reminder email
    NoteMailer.send_reminder(note, user).deliver_now
  rescue => e
    Rails.logger.error("Error processing note reminder: #{e.message}")
  end
end
