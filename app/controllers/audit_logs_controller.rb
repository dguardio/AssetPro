class AuditLogsController < ApplicationController
  def index
    @audit_logs = AuditLog.includes(:user, :auditable).order(created_at: :desc).page(params[:page])
  end

  def show
    @audit_log = AuditLog.find(params[:id])
  end

  def for_record
    @auditable = params[:auditable_type].constantize.find(params[:auditable_id])
    @audit_logs = @auditable.audit_logs.includes(:user).order(created_at: :desc).page(params[:page])
    render :index
  end
end 