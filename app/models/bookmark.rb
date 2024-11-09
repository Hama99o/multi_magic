# == Schema Information
#
# Table name: bookmarks
#
#  id                :bigint           not null, primary key
#  user_id           :bigint           not null
#  bookmarkable_type :string           not null
#  bookmarkable_id   :bigint           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_bookmarks_on_bookmarkable  (bookmarkable_type,bookmarkable_id)
#  index_bookmarks_on_user_id       (user_id)
#
class Bookmark < ApplicationRecord
  belongs_to :user
  belongs_to :bookmarkable, polymorphic: true
end
