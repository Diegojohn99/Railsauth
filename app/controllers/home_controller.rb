class HomeController < ApplicationController
  allow_unauthenticated_access only: :index

  def index
    @exercise_checks = Rails.cache.fetch("home:exercise_checks", expires_in: 5.minutes) do
      [
        {
          title: "Autenticacion nativa de Rails",
          ok: native_auth_enabled?,
          detail: "El modulo Authentication esta activo y existen controladores de sesion y passwords."
        },
        {
          title: "Contrasenas encriptadas",
          ok: password_encryption_enabled?,
          detail: "El modelo User usa has_secure_password y guarda password_digest."
        },
        {
          title: "Recuperacion por contrasena olvidada",
          ok: password_recovery_flow_enabled?,
          detail: "Existe ruta de recuperacion, PasswordsController y UserMailer.reset_password."
        },
        {
          title: "Action Mailer SMTP en desarrollo",
          ok: mailer_dev_configured?,
          detail: "Development usa delivery_method SMTP y default_url_options dinamico por entorno."
        },
        {
          title: "Variables de entorno sensibles",
          ok: smtp_env_present?,
          detail: "SMTP_USER y SMTP_PASS estan disponibles en el entorno actual."
        }
      ]
    end

    stats = Rails.cache.fetch("home:user_stats", expires_in: 30.seconds) do
      {
        users_with_digest_count: User.where.not(password_digest: [ nil, "" ]).count,
        users_total_count: User.count
      }
    end

    @users_with_digest_count = stats[:users_with_digest_count]
    @users_total_count = stats[:users_total_count]
    @recent_users = User.order(created_at: :desc).limit(5)
  end

  private
    def native_auth_enabled?
      ApplicationController.ancestors.include?(Authentication) &&
        SessionsController.instance_methods(false).include?(:create) &&
        PasswordsController.instance_methods(false).include?(:create)
    end

    def password_encryption_enabled?
      User.column_names.include?("password_digest") && User.new.respond_to?(:authenticate)
    end

    def password_recovery_flow_enabled?
      Rails.application.routes.url_helpers.respond_to?(:new_password_path) &&
        UserMailer.instance_methods(false).include?(:reset_password)
    end

    def mailer_dev_configured?
      config = Rails.application.config.action_mailer
      config.delivery_method == :smtp && config.default_url_options.present?
    end

    def smtp_env_present?
      ENV["SMTP_USER"].present? && ENV["SMTP_PASS"].present?
    end
end
