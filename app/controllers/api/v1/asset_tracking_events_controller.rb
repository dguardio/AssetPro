module Api
  module V1
    class AssetTrackingEventsController < BaseController
      before_action :set_event, only: [:show]

      def index
        @events = policy_scope(AssetTrackingEvent)
                 .includes(:asset, :location, :scanned_by)
                 .order(scanned_at: :desc)
                 .page(params[:page])

        render json: @events, each_serializer: AssetTrackingEventSerializer
      end

      def show
        render json: @event, serializer: AssetTrackingEventSerializer
      end

      def create
        @event = AssetTrackingEvent.new(event_params)
        @event.scanned_by = current_resource_owner
        @event.oauth_application = current_application
        @event.rfid_reader = current_application.rfid_reader
        @event.scanned_at = Time.current
        
        authorize @event

        if @event.save
          render json: @event, serializer: AssetTrackingEventSerializer, status: :created
        else
          render json: { errors: @event.errors }, status: :unprocessable_entity
        end
      end

      def timeline
        @events = policy_scope(AssetTrackingEvent)
                 .includes(:asset, :location, :scanned_by, :asset_assignment)
                 .order(created_at: :desc)
                 .limit(50)

        render json: @events, each_serializer: AssetTrackingEventSerializer
      end

      private

      def set_event
        @event = AssetTrackingEvent.find(params[:id])
        authorize @event
      end

      def event_params
        params.require(:asset_tracking_event).permit(:asset_id, :location_id, :event_type, :notes, :scanned_by_device_id)
      end
    end
  end
end 