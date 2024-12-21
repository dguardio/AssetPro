module Api
  module V1
    class RfidTagsController < BaseController
      before_action :set_rfid_tag, only: [:show]

      def show
        authorize @rfid_tag
        # If the rfid_tag is not found, return a 404
        # If the rfid_tag is found, return a 200
        if @rfid_tag.nil?
          render json: { error: "Rfid tag not found" }, status: :not_found
        else
          render json: @rfid_tag, serializer: RfidTagSerializer
        end
      end

      def index
        authorize RfidTag
        rfid_tags = RfidTag.includes(:asset, :last_known_location, :asset_tracking_events)
        render json: rfid_tags, each_serializer: RfidTagSerializer
      end

      def create
        authorize RfidTag
        rfid_tag = RfidTag.new(rfid_tag_params)
        if rfid_tag.save
          render json: rfid_tag, serializer: RfidTagSerializer, status: :created
        else
          render json: rfid_tag.errors, status: :unprocessable_entity
        end
      end

      def update
        authorize @rfid_tag
        if @rfid_tag.update(rfid_tag_params)
          render json: @rfid_tag, serializer: RfidTagSerializer, status: :ok
        else
          render json: @rfid_tag.errors, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @rfid_tag
        @rfid_tag.destroy
        head :no_content
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