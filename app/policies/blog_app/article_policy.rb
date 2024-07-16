class BlogApp::ArticlePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    record.user
  end

  def create?
   record.user.present?
  end

  def update?
    true
  end

  def destroy?
    show?
  end

  def restore?
    destroy?
  end

  def toggle_tag?
    destroy?
  end

  def destroy_permanently?
    destroy?
  end
end
