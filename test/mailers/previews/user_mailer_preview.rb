# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/reset_password
  def reset_password
    user = User.first || User.new(email_address: "preview@example.com", password: "password123", password_confirmation: "password123")
    UserMailer.reset_password(user)
  end
end
