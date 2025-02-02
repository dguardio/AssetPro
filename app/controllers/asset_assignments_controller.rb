class AssetAssignmentsController < ApplicationController
  before_action :set_asset_assignment, only: [:show, :edit, :update, :destroy, :check_in, :check_out]

  def index
    @q = policy_scope(AssetAssignment)
    @q = @q.includes(:asset, :user, :assigned_by).ransack(params[:q])
    @q.sorts = ['created_at desc'] if @q.sorts.empty?
    
    @asset_assignments = @q.result(distinct: true)
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

    begin
      if @asset_assignment.save
        redirect_to asset_assignments_path, notice: 'Asset assignment was successfully created.'
      else
        error_messages = @asset_assignment.errors.full_messages
        flash.now[:alert] = "Failed to create assignment: #{error_messages.join(', ')}"
        render :new, status: :unprocessable_entity
      end
    rescue StandardError => e
      # Log the full error for debugging
      Rails.logger.error "Asset Assignment Creation Error: #{e.message}\n#{e.backtrace.join("\n")}"
      
      # Check for nested errors from callbacks
      if e.cause
        flash.now[:alert] = "Error in assignment: #{e.cause.message}"
      else
        flash.now[:alert] = "Error creating assignment: #{e.message}"
      end
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @asset_assignment
    if @asset_assignment.update(asset_assignment_params)
      redirect_to @asset_assignment, notice: 'Asset assignment was successfully updated.'
    else
      error_messages = @asset_assignment.errors.full_messages
      flash.now[:alert] = "Failed to update assignment: #{error_messages.join(', ')}"
      render :edit, status: :unprocessable_entity
    end
  rescue StandardError => e
    flash.now[:alert] = "Error updating assignment: #{e.message}"
    render :edit, status: :unprocessable_entity
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

  def check_in
    authorize @asset_assignment
    @asset_assignment.checked_in_at = Time.current
    
    if @asset_assignment.save
      redirect_to @asset_assignment, notice: 'Asset has been checked in successfully.'
    else
      redirect_to @asset_assignment, alert: @asset_assignment.errors.full_messages.join(', ')
    end
  end

  def check_out
    authorize @asset_assignment
    @asset_assignment.checked_out_at = Time.current
    
    if @asset_assignment.save
      redirect_to @asset_assignment, notice: 'Asset has been checked out successfully.'
    else
      redirect_to @asset_assignment, alert: @asset_assignment.errors.full_messages.join(', ')
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