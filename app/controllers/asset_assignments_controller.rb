class AssetAssignmentsController < ApplicationController
  before_action :set_asset_assignment, only: [:show, :edit, :update, :destroy]

  def index
    @q = policy_scope(AssetAssignment)
    @q = params[:show_deleted] ? @q.only_deleted : @q
    @q = @q.ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    
    @asset_assignments = @q.result
      .includes(:asset, :user, :assigned_by)
      .references(:asset, :user)
      .page(params[:page])
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
      redirect_to asset_assignments_path, notice: 'Asset assignment was successfully created.'
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
    if @asset_assignment.destroy_fully
      redirect_to asset_assignments_url, notice: 'Asset assignment was successfully archived.'
    else
      redirect_to asset_assignments_url, alert: 'Failed to archive asset assignment.'
    end
  end

  def restore
    @asset_assignment = AssetAssignment.with_deleted.find(params[:id])
    authorize @asset_assignment
    
    if @asset_assignment.restore
      redirect_to asset_assignments_url, notice: 'Asset assignment was successfully restored.'
    else
      redirect_to asset_assignments_url, alert: 'Failed to restore asset assignment.'
    end
  end

  private

  def set_asset_assignment
    #Set asset assignment if soft deleted or not
    @asset_assignment = params[:id].present? ? AssetAssignment.with_deleted.find(params[:id]) : AssetAssignment.new
  end

  def asset_assignment_params
    params.require(:asset_assignment).permit(:asset_id, :user_id, :checked_out_at, :checked_in_at, :notes)
  end
end 