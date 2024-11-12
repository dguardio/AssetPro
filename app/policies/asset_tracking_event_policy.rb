class AssetTrackingEventPolicy < ApplicationPolicy
  def create?
    user.present? # Any authenticated user can scan
  end
end 