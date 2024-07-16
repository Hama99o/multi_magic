# == Schema Information
#
# Table name: taggings
#
#  id            :bigint           not null, primary key
#  tag_id        :bigint           not null
#  taggable_type :string           not null
#  taggable_id   :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_taggings_on_tag_id                                    (tag_id)
#  index_taggings_on_tag_id_and_taggable_id_and_taggable_type  (tag_id,taggable_id,taggable_type) UNIQUE
#  index_taggings_on_taggable                                  (taggable_type,taggable_id)
#
class Tagging < ApplicationRecord
  belongs_to :tag
  belongs_to :taggable, polymorphic: true
end
