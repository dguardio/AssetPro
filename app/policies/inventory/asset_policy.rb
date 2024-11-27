module Inventory
  class AssetPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        if user.has_role?(:admin)
          scope.all
        else
          scope.where(location_id: user.accessible_location_ids)
        end
      end
    end

    def export?
      user.has_role?(:admin) || user.has_role?(:manager)
    end

    def import?
      user.has_role?(:admin) || user.has_role?(:manager)
    end

    def index?
      true
    end

    def show?
      user.has_role?(:admin) || record.location_id.in?(user.accessible_location_ids)
    end

    def create?
      user.has_role?(:admin) || user.has_role?(:manager)
    end

    def update?
      user.has_role?(:admin) || 
        (user.has_role?(:manager) && record.location_id.in?(user.accessible_location_ids))
    end

    def destroy?
      user.has_role?(:admin)
    end
  end
end 