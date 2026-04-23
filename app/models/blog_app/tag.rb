# == Schema Information
#
# Table name: tags
#
#  id          :integer          not null, primary key
#  name        :string
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer
#  parent_id   :integer
#  position    :integer
#  description :string
#
# Indexes
#
#  index_tags_on_user_id  (user_id)
#

class BlogApp::Tag < Tag
  has_many :taggings, dependent: :destroy
end
