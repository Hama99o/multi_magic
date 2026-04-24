# == Schema Information
#
# Table name: reactions
#
#  id                :integer          not null, primary key
#  user_id           :integer          not null
#  type              :string
#  reactionable_type :string           not null
#  reactionable_id   :integer          not null
#  reaction_type     :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_reactions_on_reactionable  (reactionable_type,reactionable_id)
#  index_reactions_on_user_id       (user_id)
#

class Reaction::Like < Reaction
end
