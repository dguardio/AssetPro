class DashboardPolicy < Struct.new(:user, :dashboard)
  def index?
    user.admin? || user.manager?
  end

  def timeline?
    user.admin? || user.manager?
  end
end 