# frozen_string_literal: true

# == Schema Information
#
# Table name: favorites
#
#  id               :bigint           not null, primary key
#  favoritable_type :string           not null
#  favoritable_id   :bigint           not null
#  favoritor_type   :string           not null
#  favoritor_id     :bigint           not null
#  scope            :string           default("favorite"), not null
#  blocked          :boolean          default(FALSE), not null
#  data             :jsonb
#  role             :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  fk_favoritables                   (favoritable_id,favoritable_type)
#  fk_favorites                      (favoritor_id,favoritor_type)
#  index_favorites_on_blocked        (blocked)
#  index_favorites_on_favoritable    (favoritable_type,favoritable_id)
#  index_favorites_on_favoritor      (favoritor_type,favoritor_id)
#  index_favorites_on_scope          (scope)
#  uniq_favorites__and_favoritables  (favoritable_type,favoritable_id,favoritor_type,favoritor_id,scope) UNIQUE
#
class Favorite < ApplicationRecord
  extend ActsAsFavoritor::FavoriteScopes

  enum role: {
    viewer: 0,   # Can only view
    contributor: 1,   # Can view and contribute (update)
    administrator: 2,   # Can delete, invite, update, and view
    owner: 3   # Highest level of access, can perform all actions including managing administrators
  }


  belongs_to :favoritable, polymorphic: true
  belongs_to :favoritor, polymorphic: true

  def block!
    update!(blocked: true)
  end
end
