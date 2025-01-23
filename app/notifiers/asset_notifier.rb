class AssetNotifier < ApplicationNotifier
  deliver_by :email, mailer: 'AssetMailer'
  # deliver_by :database

  def maintenance_due
    deliver(params[:asset].assigned_to)
    deliver(User.with_role(:manager))
  end

  def location_changed
    deliver(params[:asset].assigned_to)
  end

  def assignment_created
    deliver(params[:asset].assigned_to)
  end

  def assignment_removed
    deliver(params[:previous_assignee])
  end
end 