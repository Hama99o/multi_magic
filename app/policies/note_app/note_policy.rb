class NoteApp::NotePolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end

  def show?
    user == record.owner || record.shared_with_users.where(id: user.id).present?
  end

  def create?
    user.present?
  end

  def update?
    return true if user == record.owner
    role = record.shares.find_by(shared_with_user: user).role
    ['contributor', 'administrator'].include?(role)
  end

  def destroy?
    return true if user == record.owner
    role = record.shares.find_by(shared_with_user: user).role
    'administrator' == role
  end

  def share_with_user_toggle?
    destroy?
  end

  def restore?
    destroy?
  end

  def destroy_permanently?
    destroy?
  end
end
