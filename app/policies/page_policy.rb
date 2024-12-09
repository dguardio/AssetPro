class PagePolicy < ApplicationPolicy
  def home?
    true  # Allow access to everyone
  end

  def about?
    true
  end

  def contact?
    true
  end
end 