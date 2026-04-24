# == Schema Information
#
# Table name: images
#
#  id             :integer          not null, primary key
#  file           :string
#  imageable_type :string           not null
#  imageable_id   :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_images_on_imageable  (imageable_type,imageable_id)
#

class Image < ApplicationRecord
  belongs_to :imageable, polymorphic: true
  has_one_attached :file # ActiveStorage attachment
  validates :file,
            attached: false,
            presence: true,
            content_type: ['image/png', 'image/jpeg', 'image/gif', 'image/webp'],
            size: { less_than: 10.megabytes, message: 'error, file size exceeding 10Mb.' }
end
