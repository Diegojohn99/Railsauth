require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "reset_password" do
    user = User.new(email_address: "test@example.com")
    mail = UserMailer.reset_password(user)

    assert_equal "Restablece tu contrasena", mail.subject
    assert_equal [ "test@example.com" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Recuperacion de contrasena", mail.body.encoded
  end
end
