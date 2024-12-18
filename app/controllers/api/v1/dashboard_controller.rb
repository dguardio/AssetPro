module Api
  module V1
    class DashboardController < BaseController
      def index
        dashboard = Dashboard.new(
          metrics: {
            total_assets: Asset.count,
            total_investment: Asset.sum('purchase_price * quantity'),
            total_licenses: License.count,
            available_assets: Asset.available.count,
            in_use_assets: Asset.in_use.count,
            maintenance_assets: Asset.in_maintenance.count
          },
          assets_by_status: Asset.group(:status).count,
          assets_by_category: Category.joins(:assets).group('categories.name').count,
          assets_by_location: Location.joins(:assets).group('locations.name').count,
          recent_activities: AssetTrackingEvent.includes(:asset, :location, :scanned_by)
                                             .order(created_at: :desc)
                                             .limit(10)
        )
        
        render json: dashboard
      end
    end
  end
end 