class AuditLogsController < ApplicationController
  def index
    authorize :audit_log
    
    @q = policy_scope(AuditLog).ransack(params[:q])
    @audit_logs = @q.result
                   .includes(:user, :auditable)
                   .order(created_at: :desc)
                   .page(params[:page])
  end

  def show
    @audit_log = AuditLog.find(params[:id])
    authorize @audit_log
  end

  def for_record
    @auditable = params[:auditable_type].constantize.find(params[:auditable_id])
    authorize AuditLog
    @audit_logs = @auditable.audit_logs.includes(:user).order(created_at: :desc).page(params[:page])
    render :index
  end

  private

  def audit_log_params
    params.require(:audit_log).permit(:action, :auditable_type, :auditable_id)
  end
end 