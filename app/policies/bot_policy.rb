class BotPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def create?
      !user.admin?
    end

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.admin?
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end
end
