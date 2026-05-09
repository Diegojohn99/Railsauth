class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV.fetch("SMTP_FROM", ENV.fetch("SMTP_USER", "no-reply@example.com")) }
  layout "mailer"
end
