module Api
  module V1
    class ScansController < BaseController
      before_action :verify_reader

      def create
        rfid_tag = RfidTag.active.find_by(rfid_number: scan_params[:rfid_number])
        
        if rfid_tag.nil?
          render json: { error: 'Invalid RFID tag' }, status: :not_found
          return
        end

        @tracking_event = AssetTrackingEvent.new(
          asset: rfid_tag.asset,
          location_id: scan_params[:location_id],
          rfid_number: scan_params[:rfid_number],
          event_type: scan_params[:event_type] || 'movement',
          scanned_by: current_resource_owner,
          scanned_by_device: @current_reader,
          scanned_at: Time.current,
          oauth_application: current_application
        )

        if @tracking_event.save
          # Update RFID tag's last known location
          rfid_tag.update(
            last_known_location_id: scan_params[:location_id],
            last_scanned_at: Time.current
          )
          
          render json: @tracking_event, 
                 serializer: AssetTrackingEventSerializer,
                 status: :created
        else
          render json: { errors: @tracking_event.errors }, 
                 status: :unprocessable_entity
        end
      end

      private

      def scan_params
        params.require(:scan).permit(
          :rfid_number,
          :location_id,
          :event_type,
          :notes
        )
      end

      def verify_reader
        @current_reader = RfidReader.find_by(
          oauth_application_id: current_application.id
        )
        
        unless @current_reader&.active?
          render json: { error: 'Unauthorized RFID reader' }, 
                 status: :unauthorized
        end
      end
    end
  end
end 