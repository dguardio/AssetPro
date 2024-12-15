module Api
  module V1
    class LocationsController < BaseController
      before_action :set_location, only: [:show]

      def index
        @locations = policy_scope(Location)
                    .includes(:assets)
                    .order(name: :asc)
                    .page(params[:page])
        
        render json: {
          data: ActiveModel::SerializableResource.new(@locations, each_serializer: LocationSerializer),
          meta: pagination_meta(@locations)
        }
      end

      def show
        authorize @location
        render json: @location, 
               serializer: LocationSerializer,
               include: ['assets', 'asset_tracking_events']
      end

      private

      def set_location
        @location = Location.includes(:assets, :asset_tracking_events)
                          .find(params[:id])
      end
    end
  end
end
