class AssetRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_asset_request, only: [:show, :edit, :update, :destroy, :approve, :reject]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @q = policy_scope(AssetRequest).ransack(params[:q])
    @asset_requests = @q.result
      .includes(:asset, :user, :reviewed_by)
      .order(created_at: :desc)
      .page(params[:page])
  end

  def show
    authorize @asset_request
  end

  def new
    @asset_request = AssetRequest.new
    @asset_request.asset_id = params[:asset_id] if params[:asset_id]
    authorize @asset_request
  end

  def create
    @asset_request = current_user.asset_requests.build(asset_request_params)
    authorize @asset_request

    if @asset_request.save
      redirect_to asset_requests_path, notice: 'Asset request was successfully created.'
    else
      render :new
    end
  end

  def approve
    authorize @asset_request
    @asset_request.reviewed_by = current_user
    @asset_request.reviewed_at = Time.current
    
    if @asset_request.update(status: :approved)
      AssetAssignment.create!(
        asset: @asset_request.asset,
        user: @asset_request.user,
        assigned_by: current_user,
        checked_out_at: @asset_request.requested_from,
        notes: "Auto-assigned from request ##{@asset_request.id}"
      )
      redirect_to asset_requests_path, notice: 'Asset request was approved and assigned.'
    else
      redirect_to asset_requests_path, alert: 'Failed to approve asset request.'
    end
  end

  def reject
    authorize @asset_request
    @asset_request.reviewed_by = current_user
    @asset_request.reviewed_at = Time.current
    
    if @asset_request.update(status: :rejected, rejection_reason: params[:rejection_reason])
      redirect_to asset_requests_path, notice: 'Asset request was rejected.'
    else
      redirect_to asset_requests_path, alert: 'Failed to reject asset request.'
    end
  end

  def edit
    authorize @asset_request
  end

  def update
    authorize @asset_request
    
    if @asset_request.update(asset_request_params)
      redirect_to asset_request_path(@asset_request), notice: 'Asset request was successfully updated.'
    else
      render :edit
    end
  end

  private

  def set_asset_request
    #Set asset request if soft deleted or not
    @asset_request = params[:id].present? ? AssetRequest.with_deleted.find(params[:id]) : AssetRequest.new
  end

  def asset_request_params
    params.require(:asset_request).permit(
      :asset_id, :purpose, :requested_from, :requested_until
    )
  end
end 