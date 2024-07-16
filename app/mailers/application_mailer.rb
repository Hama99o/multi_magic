class ApplicationMailer < ActionMailer::Base
  include EmailHelper
  default from: CompanyInfo.no_reply
  layout "mailer"
end
