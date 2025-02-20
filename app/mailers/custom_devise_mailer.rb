class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'
  
  def lock(record, opts={})
    @reason = opts[:reason]
    devise_mail(record, :lock)
  end

  def unlock(record, opts={})
    @reason = opts[:reason]
    devise_mail(record, :unlock)
  end
end 