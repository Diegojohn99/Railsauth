class SendPasswordResetEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return if user.nil?

    UserMailer.reset_password(user).deliver_now
  rescue Net::OpenTimeout, Net::ReadTimeout, Timeout::Error => e
    Rails.logger.error("SMTP timeout en job de recuperacion: #{e.class} - #{e.message}")

    if ENV["SMTP_PROVIDER"].to_s.downcase == "brevo"
      sent, brevo_error = BrevoEmailClient.deliver_password_reset(
        user: user,
        reset_url: Rails.application.routes.url_helpers.edit_password_url(token: user.password_reset_token)
      )

      Rails.logger.error("Fallback Brevo API fallo: #{brevo_error}") unless sent
    end
  rescue StandardError => e
    Rails.logger.error("Error en SendPasswordResetEmailJob: #{e.class} - #{e.message}")
  end
end
