class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.has_role?(:admin)
      can :manage, :all
    elsif user.has_role?(:manager)
      can :read, :all
      can :manage, Asset
      can :manage, AssetAssignment
      can :manage, MaintenanceRecord
      can [:read, :create], Category
      can [:read, :create], Location
    elsif user.has_role?(:employee)
      can :read, Asset
      can [:read, :create], AssetAssignment, user_id: user.id
      can :read, MaintenanceRecord
      can :read, Category
      can :read, Location
    end
  end
end 