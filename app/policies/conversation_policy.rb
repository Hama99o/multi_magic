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
    # record.sender_id == user.id || record.recipient_id == user.id
    true
  end
end
