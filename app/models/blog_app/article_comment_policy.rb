class BlogApp::ArticleCommentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(commentable_type: 'BlogApp::Article')  # Only article-related comments
    end
  end

  def show?
    record.commentable.published? || user == record.commentable.user  # Only show if the article is published or the user owns the article
  end

  def create?
    user.present? && record.commentable.published?  # Can only create a comment on a published article, and the user must be logged in
  end

  def update?
    user.present? && record.user == user  # Only the comment author can update their comment
  end

  def destroy?
    user.present? && (record.user == user || user == record.commentable.user)  # Comment author or article owner can delete
  end

  def reply?
    create?  # Reuse the create logic for replies, meaning user must be logged in and the article must be published
  end

  def destroy_permanently?
    destroy?  # The same logic as destroy (author or article owner)
  end

  def restore?
    destroy?  # Only allow restoration if destroy is permitted
  end
end
