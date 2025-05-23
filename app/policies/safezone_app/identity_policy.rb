module SafezoneApp
  class IdentityPolicy < ApplicationPolicy
    def index?
      user.present?
    end

    def show?
      user.present? && record.user == user
    end

    def create?
      user.present?
    end

    def update?
      user.present? && record.user == user
    end

    def destroy?
      user.present? && record.user == user
    end
  end
end
