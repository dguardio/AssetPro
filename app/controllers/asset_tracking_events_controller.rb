class AssetTrackingEventsController < ApplicationController
  before_action :set_asset_tracking_event, only: [:show, :edit, :update, :destroy]

  def index
    @q = policy_scope(AssetTrackingEvent).ransack(params[:q])
    @asset_tracking_events = @q.result(distinct: true)
                              .includes(:asset, :location, :scanned_by)
                              .order(scanned_at: :desc)
                              .page(params[:page])
  end

  def show
    authorize @asset_tracking_event
  end

  def new
    @asset_tracking_event = AssetTrackingEvent.new
    authorize @asset_tracking_event
  end

  def create
    @asset_tracking_event = AssetTrackingEvent.new(asset_tracking_event_params)
    @asset_tracking_event.scanned_by = current_user
    @asset_tracking_event.scanned_at = Time.current
    
    authorize @asset_tracking_event

    if @asset_tracking_event.save
      redirect_to @asset_tracking_event, notice: 'Asset tracking event was successfully created.'
    else
      render :new
    end
  end

  private

  def set_asset_tracking_event
    @asset_tracking_event = AssetTrackingEvent.find(params[:id])
  end

  def asset_tracking_event_params
    params.require(:asset_tracking_event).permit(
      :asset_id, :location_id, :event_type, :rfid_number
    )
  end
end 