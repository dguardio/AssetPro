class ScannerInterfacePolicy < ApplicationPolicy
  # def index?
  #   user.present?
  # end

  def scan?
    user.present?
  end

  def recent_scans?
    user.present?
  end

  # def update_location?
  #   user.present?
  # end
end 