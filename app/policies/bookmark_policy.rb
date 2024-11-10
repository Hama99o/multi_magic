# app/policies/blog_app/bookmark_policy.rb
class BookmarkPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    true  # Anyone can view bookmarks
  end

  def create?
    user.present?  # Only logged-in users can create bookmarks
  end

  def destroy?
    user.present? && record.user == user  # Only the bookmark author can delete their bookmark
  end
end
