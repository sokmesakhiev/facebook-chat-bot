class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    index?
  end

  def create?
    index?
  end

  def new?
    create?
  end

  def update?
    index?
  end

  def edit?
    update?
  end

  def destroy?
    index?
  end
end
