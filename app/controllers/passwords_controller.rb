class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: "Try again later." }

  def new
  end

  def create
    if user = User.find_by(email_address: params[:email_address])
      begin
        smtp_user = ENV["SMTP_USER"].to_s.strip
        smtp_password = ENV["SMTP_PASS"].to_s.delete(" ").strip

        if Rails.env.production? && (smtp_user.blank? || smtp_password.blank?)
          raise "SMTP no configurado en entorno de produccion"
        end

        # Password reset is a critical path: deliver synchronously so errors are visible.
        UserMailer.reset_password(user).deliver_now
        redirect_to new_session_path, notice: "Correo de recuperacion enviado. Revisa tu bandeja de entrada."
      rescue StandardError => e
        Rails.logger.error(
          "Error enviando recuperacion: #{e.class} - #{e.message} " \
          "(smtp_user_present=#{smtp_user.present?}, smtp_from_present=#{ENV['SMTP_FROM'].to_s.strip.present?})"
        )

        user_message = case e
        when Net::SMTPAuthenticationError
          "Error SMTP: usuario o app password incorrectos."
        when Net::OpenTimeout, Net::ReadTimeout, Timeout::Error
          "Error SMTP: timeout de conexion. En Render, usa proveedor SMTP transaccional (SMTP_PROVIDER=brevo)."
        when SocketError
          "Error SMTP: no se pudo resolver el servidor de correo."
        else
          "No se pudo enviar el correo de recuperacion. Intenta nuevamente."
        end

        redirect_to new_password_path, alert: user_message
      end
      return
    end

    redirect_to new_session_path, notice: "Si existe una cuenta con ese correo, recibiras instrucciones para recuperar tu contrasena."
  end

  def edit
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: "Password has been reset."
    else
      redirect_to edit_password_path(params[:token]), alert: "Passwords did not match."
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end
