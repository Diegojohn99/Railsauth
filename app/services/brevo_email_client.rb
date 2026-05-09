require "json"
require "net/http"

class BrevoEmailClient
  API_URL = URI("https://api.brevo.com/v3/smtp/email")

  def self.deliver_password_reset(user:, reset_url:)
    api_key = ENV["BREVO_API_KEY"].to_s.strip
    return [ false, "BREVO_API_KEY no configurada" ] if api_key.blank?

    sender_email = ENV.fetch("SMTP_FROM", ENV["SMTP_USER"]).to_s.strip
    return [ false, "SMTP_FROM no configurado" ] if sender_email.blank?

    payload = {
      sender: {
        name: ENV.fetch("SMTP_FROM_NAME", "RailsAuth"),
        email: sender_email
      },
      to: [ { email: user.email_address } ],
      subject: "Restablece tu contrasena - RailsAuth",
      htmlContent: <<~HTML,
        <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #1f2937; max-width: 560px; margin: 0 auto; padding: 24px;">
          <h1 style="margin: 0 0 12px; font-size: 24px; color: #111827;">Restablece tu contrasena</h1>
          <p style="margin: 0 0 12px;">Hola <strong>#{user.email_address}</strong>,</p>
          <p style="margin: 0 0 16px;">Recibimos una solicitud para restablecer la contrasena de tu cuenta.</p>
          <p style="margin: 0 0 20px;">
            <a href="#{reset_url}" style="display:inline-block;background:#2563eb;color:#ffffff;text-decoration:none;padding:10px 16px;border-radius:8px;font-weight:600;">Restablecer contrasena</a>
          </p>
          <p style="margin: 0; font-size: 14px; color: #6b7280;">Si no solicitaste este cambio, ignora este correo.</p>
        </div>
      HTML
      textContent: <<~TEXT
        Restablece tu contrasena - RailsAuth

        Hola #{user.email_address},

        Recibimos una solicitud para restablecer la contrasena de tu cuenta.

        Usa este enlace para crear una nueva contrasena:
        #{reset_url}

        Si no solicitaste este cambio, ignora este correo.
      TEXT
    }

    request = Net::HTTP::Post.new(API_URL)
    request["accept"] = "application/json"
    request["content-type"] = "application/json"
    request["api-key"] = api_key
    request.body = payload.to_json

    response = Net::HTTP.start(API_URL.host, API_URL.port, use_ssl: true, open_timeout: 15, read_timeout: 20) do |http|
      http.request(request)
    end

    return [ true, nil ] if response.code.to_i.between?(200, 299)

    [ false, "Brevo API HTTP #{response.code}: #{response.body.to_s[0, 300]}" ]
  rescue StandardError => e
    [ false, "Brevo API error: #{e.class} - #{e.message}" ]
  end
end
