# == Schema Information
#
# Table name: note_app_reminders
#
#  id            :bigint           not null, primary key
#  note_id       :bigint
#  user_id       :bigint
#  reminder_time :datetime
#  is_completed  :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_note_app_reminders_on_note_id  (note_id)
#  index_note_app_reminders_on_user_id  (user_id)
#
class NoteApp::Reminder < ApplicationRecord
end
