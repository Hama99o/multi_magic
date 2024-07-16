class NoteMailer < ApplicationMailer
  def share_note(note, email)
    @note = note
    @email = email
    @link = email_redirect_to_front("/note_app/notes?note_id=#{@note.id}")
    mail(to: @email, subject: "You've received a shared note")
  end

  def send_reminder(note, user)
    @note = note
    @user = user

    mail(to: @user.email, subject: "Reminder: #{@note.title}")
  end
end
