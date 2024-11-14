class MyFinanceApp::ExpensePolicy < ApplicationPolicy
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
    true
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

  def destroy_permanently?
    show?
  end

  def total_expenses_last_years_or_months?
    show?
  end
end