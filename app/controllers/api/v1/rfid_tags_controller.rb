module Api
  module V1
    class RfidTagsController < BaseController
      before_action :set_rfid_tag, only: [:show]

      def show
        authorize @rfid_tag
        render json: @rfid_tag, serializer: RfidTagSerializer
      end

      private

      def set_rfid_tag
        @rfid_tag = RfidTag.includes(:asset, :last_known_location, :asset_tracking_events)
                          .find(params[:id])
      end

      def rfid_tag_params
        params.require(:rfid_tag).permit(
          :rfid_number,
          :asset_id,
          :active,
          :last_known_location_id,
          :last_scanned_at,
          :notes
        )
      end
    end
  end
end 