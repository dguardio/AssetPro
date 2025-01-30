module Noticed
  class NotificationPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        scope.where(recipient: user)
      end
    end

    def index?
      true
    end

    def mark_as_read?
      record.recipient == user
    end

    def mark_all_as_read?
      true
    end
  end
end 