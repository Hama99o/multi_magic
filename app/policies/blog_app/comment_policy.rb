class BlogApp::CommentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    true  # Anyone can view comments
  end

  def create?
    user.present?  # Only logged-in users can create comments
  end

  def update?
    user.present? && record.user == user  # Only the comment author can update their comment
  end

  def destroy?
    user.present? && record.user == user  # Only the comment author can delete their comment
  end

  def reply?
    create?  # Only logged-in users can reply to comments
  end

  def destroy_permanently?
    destroy?  # Only the comment author can delete permanently (if such functionality exists)
  end

  def restore?
    destroy?  # Only the comment author can restore their comment
  end
end
