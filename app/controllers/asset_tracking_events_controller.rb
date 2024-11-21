class AssetTrackingEventsController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = AssetTrackingEvent.ransack(params[:q])
    @asset_tracking_events = @q.result.includes(:asset, :location, :scanned_by)
                              .page(params[:page])
                              .per(25)
  end

  # API endpoint for RFID scanner
  def create
    @tracking_event = AssetTrackingEvent.new(tracking_event_params)
    @tracking_event.scanned_by = current_user
    @tracking_event.scanned_at = Time.current
    
    authorize @tracking_event

    if @tracking_event.save
      respond_to do |format|
        format.json { render json: @tracking_event, status: :created }
        format.html { redirect_to asset_path(@tracking_event.asset), notice: 'Location updated.' }
      end
    else
      respond_to do |format|
        format.json { render json: @tracking_event.errors, status: :unprocessable_entity }
        format.html { redirect_to asset_path(@tracking_event.asset), alert: 'Error updating location.' }
      end
    end
  end

  private

  def tracking_event_params
    params.require(:asset_tracking_event).permit(
      :asset_id,
      :location_id,
      :event_type,
      :rfid_number
    )
  end
end 