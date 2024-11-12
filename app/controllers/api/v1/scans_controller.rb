module Api
  module V1
    class ScansController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!

      def create
        rfid_tag = RfidTag.active.find_by(rfid_number: scan_params[:rfid_number])
        
        if rfid_tag
          @tracking_event = AssetTrackingEvent.new(
            asset: rfid_tag.asset,
            location_id: scan_params[:location_id],
            rfid_number: scan_params[:rfid_number],
            event_type: scan_params[:event_type] || 'location_update',
            scanned_by: current_user,
            scanned_at: Time.current
          )

          if @tracking_event.save
            render json: { status: 'success', tracking_event: @tracking_event }, status: :created
          else
            render json: {
              status: 'error',
              message: 'Failed to record scan',
              errors: @tracking_event.errors.full_messages
            }, status: :unprocessable_entity
          end
        else
          render json: {
            status: 'error',
            message: 'Invalid or inactive RFID tag'
          }, status: :not_found
        end
      end

      private

      def scan_params
        params.require(:scan).permit(:rfid_number, :location_id, :event_type)
      end
    end
  end
end 