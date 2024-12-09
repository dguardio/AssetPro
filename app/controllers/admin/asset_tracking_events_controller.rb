class Admin::AssetTrackingEventsController < ApplicationController
  helper Admin::AssetTrackingEventsHelper
  
  before_action :authorize_asset_tracking
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: [:index, :timeline]

  def timeline
    base_query = policy_scope(AssetTrackingEvent)
    
    @q = base_query.ransack(params[:q])
    @events = @q.result(distinct: true)
                .includes(:asset, :location, :scanned_by, :asset_assignment)
                .order(created_at: :desc)
                .limit(50)

    @events = apply_user_filters(@events)

    respond_to do |format|
      format.html
      format.turbo_stream if turbo_frame_request?
    end
  end

  private

  def authorize_asset_tracking
    authorize AssetTrackingEvent
  end

  def apply_user_filters(events)
    case current_user.role
    when 'admin'
      events
    when 'manager'
      events.where(location_id: current_user.managed_location_ids)
    when 'security'
      events.where(asset_id: current_user.assigned_asset_ids)
    else
      events.none
    end
  end
end 