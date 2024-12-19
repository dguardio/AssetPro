class ApplicationMailer < ActionMailer::Base
  default from: "notifications@getassetpro.com"
  layout 'mailer'
  
  def self.mailer_name
    "AssetPro System"
  end
end
