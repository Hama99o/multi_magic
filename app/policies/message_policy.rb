# frozen_string_literal: true

class MessagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.admin_or_above?
        scope.all
      else
        scope.joins(:conversation).where(
          "conversations.sender_id = ? OR conversations.recipient_id = ?", user.id, user.id
        )
      end
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
    record.conversation.sender_id == user.id || record.conversation.recipient_id == user.id
  end
end
