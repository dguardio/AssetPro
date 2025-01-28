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
          scanned_by: doorkeeper_token.resource_owner_id ? current_resource_owner : nil,
          scanned_by_device: @current_reader,
          scanned_at: Time.current,
          oauth_application: current_application
        )

        if @tracking_event.save
          rfid_tag.update(last_scanned_at: Time.current)
          notify_scan_events
          render json: @tracking_event, 
                 serializer: AssetTrackingEventSerializer,
                 status: :created
        else
          render json: { errors: @tracking_event.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end

      private

      def scan_params
        params.require(:scan).permit(:rfid_number, :location_id, :event_type, :notes, :scanned_by_device_id, :dev_id)
      end

      def verify_reader
        # @current_reader = RfidReader.find_by(oauth_application_id: current_application.id)
        @current_reader = RfidReader.find_by(reader_id: scan_params[:dev_id]) ||RfidReader.find_by(id: scan_params[:scanned_by_device_id])


        unless @current_reader&.active?
          render json: { error: 'Unauthorized RFID reader' }, status: :unauthorized
        end
      end

      def notify_scan_events
        if @current_reader&.active?
          # Log successful scan
          Rails.logger.info("Authorized scan by reader: #{@current_reader.reader_id}")
        else
          RfidNotifier.with(
            reader: @current_reader,
            location: Location.find(scan_params[:location_id])
          ).unauthorized_scan_attempt
        end

        if @tracking_event.location_id_changed?
          AssetNotifier.with(
            asset: @tracking_event.asset
          ).location_changed
        end
      end
    end
  end
end 