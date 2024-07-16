class ContactApp::ContactPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end

  def show?
    user == record.user
  end

  def create?
    user.present?
  end

  def update?
    show?
  end

  def destroy?
    show?
  end


  def restore?
    show?
  end

  def import_vcard?
    user.present?
  end

  def export_vcard?
    show?
  end
end
