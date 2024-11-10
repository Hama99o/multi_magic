# == Schema Information
#
# Table name: views
#
#  id            :bigint           not null, primary key
#  viewable_type :string           not null
#  viewable_id   :bigint           not null
#  user_id       :bigint
#  ip_address    :string
#  user_agent    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_views_on_user_id                (user_id)
#  index_views_on_viewable               (viewable_type,viewable_id)
#  index_views_on_viewable_and_ip_agent  (viewable_type,viewable_id,ip_address,user_agent) UNIQUE WHERE (user_id IS NULL)
#  index_views_on_viewable_and_user      (viewable_type,viewable_id,user_id) UNIQUE WHERE (user_id IS NOT NULL)
#
# app/models/view.rb
class View < ApplicationRecord
  belongs_to :viewable, polymorphic: true
  belongs_to :user, optional: true  # user_id will be nil for guest views
end
