# == Schema Information
#
# Table name: note_app_shares
#
#  id                  :bigint           not null, primary key
#  note_id             :bigint
#  shared_with_user_id :bigint
#  role                :integer          default("viewer"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_note_app_shares_on_note_id              (note_id)
#  index_note_app_shares_on_shared_with_user_id  (shared_with_user_id)
#
class NoteApp::Share < ApplicationRecord
  belongs_to :note, class_name: 'NoteApp::Note'
  belongs_to :shared_with_user, class_name: 'User'

  enum role: {
    viewer: 0,   # Can only view
    contributor: 1,   # Can view and contribute (update)
    administrator: 2   # Can delete, invite, update, and view Highest level of access, can perform all actions including managing administrators
  }

end
