module SafezoneApp
  class PasswordManagerPolicy < ApplicationPolicy
    def index?
      user.present?
    end

    def show?
      user.present? && record.owner == user
    end

    def create?
      user.present?
    end

    def update?
      user.present? && record.owner == user
    end

    def destroy?
      user.present? && record.owner == user
    end
  end
end
