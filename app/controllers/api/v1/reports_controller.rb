module Api
  module V1
    class ReportsController < BaseController
      before_action :doorkeeper_authorize!

      def asset_movement
        @movements = AssetTrackingEvent.includes(:asset, :location, :scanned_by)
                                     .where(created_at: date_range)
                                     .order(created_at: :desc)
                                     .page(params[:page])

        render json: @movements, 
               each_serializer: AssetMovementReportSerializer,
               meta: pagination_meta(@movements)
      end

      private

      def date_range
        start_date = params[:start_date].presence || 30.days.ago
        end_date = params[:end_date].presence || Time.current
        start_date.beginning_of_day..end_date.end_of_day
      end

      def pagination_meta(object)
        {
          current_page: object.current_page,
          next_page: object.next_page,
          prev_page: object.prev_page,
          total_pages: object.total_pages,
          total_count: object.total_count
        }
      end
    end
  end
end 