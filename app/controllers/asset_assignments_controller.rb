class AssetAssignmentsController < ApplicationController
  before_action :set_asset_assignment, only: [:show, :edit, :update, :destroy]

  def index
    @q = policy_scope(AssetAssignment).ransack(params[:q])
    @asset_assignments = @q.result.includes(:asset, :user, :assigned_by).page(params[:page])
  end

  def show
    authorize @asset_assignment
  end

  def new
    @asset_assignment = AssetAssignment.new
    authorize @asset_assignment
  end

  def edit
    authorize @asset_assignment
  end

  def create
    @asset_assignment = AssetAssignment.new(asset_assignment_params)
    @asset_assignment.assigned_by = current_user
    authorize @asset_assignment

    if @asset_assignment.save
      redirect_to @asset_assignment, notice: 'Asset assignment was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @asset_assignment
    if @asset_assignment.update(asset_assignment_params)
      redirect_to @asset_assignment, notice: 'Asset assignment was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @asset_assignment
    @asset_assignment.destroy
    redirect_to asset_assignments_url, notice: 'Asset assignment was successfully deleted.'
  end

  private

  def set_asset_assignment
    @asset_assignment = AssetAssignment.find(params[:id])
  end

  def asset_assignment_params
    params.require(:asset_assignment).permit(:asset_id, :user_id, :checked_out_at, :checked_in_at, :notes)
  end
end 