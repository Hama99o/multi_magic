class ReactionPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    true  # Anyone can view ceactions
  end

  def create?
    user.present?  # Only logged-in users can create ceactions
  end

  def destroy?
    user.present? && record.user == user  # Only the ceaction author can delete their ceaction
  end
end
