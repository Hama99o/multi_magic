# == Schema Information
#
# Table name: tags
#
#  id          :bigint           not null, primary key
#  name        :string
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint
#  parent_id   :bigint
#  position    :integer
#  description :string
#
# Indexes
#
#  index_tags_on_user_id  (user_id)
#
class MyFinanceApp::Tag < Tag
end
