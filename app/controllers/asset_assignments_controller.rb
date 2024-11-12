class AssetAssignmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_asset_assignment, only: [:show, :edit, :update, :destroy]
  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    @q = policy_scope(AssetAssignment).ransack(params[:q])
    @asset_assignments = @q.result
                          .includes(:user, :asset)
                          .order(params[:sort] || 'created_at DESC')
                          .page(params[:page]).per(10)
  end

  def show
    authorize @asset_assignment
  end

  def new
    @asset_assignment = AssetAssignment.new
    authorize @asset_assignment
  end

  def create
    @asset_assignment = AssetAssignment.new(asset_assignment_params)
    authorize @asset_assignment

    if @asset_assignment.save
      redirect_to @asset_assignment, notice: 'Asset assignment was successfully created.'
    else
      render :new
    end
  end

  def destroy
    authorize @asset_assignment
    @asset_assignment.destroy
    redirect_to asset_assignments_url, notice: 'Asset assignment was successfully removed.'
  end

  private

  def set_asset_assignment
    @asset_assignment = AssetAssignment.find(params[:id])
  end

  def asset_assignment_params
    params.require(:asset_assignment).permit(:user_id, :asset_id, :assigned_date, :return_date)
  end
end 