class ScannerInterfaceController < ApplicationController
  before_action :authenticate_user!

  def scan
    authorize :scanner_interface, :scan?
    @locations = Location.order(:name)
    @recent_scans = ::AssetTrackingEvent.where(scanned_by: current_user)
                                     .includes(:asset, :location)
                                     .order(created_at: :desc)
                                     .limit(10)
  end

  def recent_scans
    authorize :scanner_interface, :recent_scans?
    @recent_scans = ::AssetTrackingEvent.where(scanned_by: current_user)
                                     .includes(:asset, :location)
                                     .order(created_at: :desc)
                                     .limit(10)
    render partial: 'scan_result', collection: @recent_scans, as: :scan
  end
end 