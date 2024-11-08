# frozen_string_literal: true

class MessagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def show?
    user.admin_or_above? || participant?
  end

  def create?
    user.admin_or_above? || participant?
  end

  def update?
    user.admin_or_above? || (participant? && record.user_id == user.id)
  end

  def destroy?
    user.admin_or_above? || (participant? && record.user_id == user.id)
  end

  private

  def participant?
    true
    # record.conversation.sender_id == user.id || record.conversation.recipient_id == user.id
  end
end
