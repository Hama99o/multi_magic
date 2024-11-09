# == Schema Information
#
# Table name: reactions
#
#  id                :bigint           not null, primary key
#  user_id           :bigint           not null
#  type              :string
#  reactionable_type :string           not null
#  reactionable_id   :bigint           not null
#  reaction_type     :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_reactions_on_reactionable  (reactionable_type,reactionable_id)
#  index_reactions_on_user_id       (user_id)
#
FactoryBot.define do
  factory :reaction do
    user { nil }
    reactionable { nil }
    reaction_type { 1 }
  end
end
