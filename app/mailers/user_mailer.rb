class UserMailer < ApplicationMailer
  def reset_password(user)
    @user = user
    mail to: @user.email_address, subject: "Restablece tu contrasena"
  end
end
