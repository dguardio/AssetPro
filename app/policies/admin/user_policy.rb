module Admin
  class UserPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if user.admin?
          scope.all
        else
          scope.none
        end
      end
    end

    def index?
      user.admin?
    end

    # ... other policy methods ...
  end
end 