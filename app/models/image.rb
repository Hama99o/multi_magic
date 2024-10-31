# == Schema Information
#
# Table name: images
#
#  id             :bigint           not null, primary key
#  file           :string
#  imageable_type :string           not null
#  imageable_id   :bigint           not null
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
            content_type: ["image/png", "image/jpg", "image/jpeg", "image/gif", "image/webp"],
            processable_image: false,
            size: { less_than: 10.megabytes, message: "error, file size exceeding 10Mb." }

end
