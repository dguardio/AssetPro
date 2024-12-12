module Profile
  class PasswordPolicy < ApplicationPolicy
    def edit?
      user.present? && user == record
    end

    def update?
      edit?
    end
  end
end 