module Api
  module V1
    class DashboardController < BaseController

      def index
        stats = {
          total_assets: Asset.count,
          assets_in_use: Asset.where(status: 'in_use').count,
          assets_available: Asset.where(status: 'available').count,
          recent_movements: AssetTrackingEvent.includes(:asset, :location)
                                           .order(created_at: :desc)
                                           .limit(10),
          active_assignments: AssetAssignment.where(checked_in_at: nil).count
        }

        @dashboard = Dashboard.new(stats)
        render json: @dashboard, serializer: DashboardSerializer
      end
    end
  end
end 