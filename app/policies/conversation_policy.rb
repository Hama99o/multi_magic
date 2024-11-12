# frozen_string_literal: true

class ConversationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.involving(user)
    end
  end

  def show?
    user.admin_or_above? || participant?
  end

  def create?
    user.admin_or_above? || true
  end

  def update?
    false
  end

  def destroy?
    user.admin_or_above? || participant?
  end

  private

  def participant?
    return true unless record.is_group

    admin_user_ids = record.conversation_members.active.where(is_admin: true).pluck(:user_id)
    admin_user_ids.include?(user.id)
    true
  end
end
