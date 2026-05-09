require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_registration_url
    assert_response :success
  end

  test "should create user" do
    assert_difference("User.count", 1) do
      post registration_url, params: {
        user: {
          email_address: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to root_url
  end

  test "should show custom message when email already exists" do
    existing_user = User.create!(email_address: "duplicate@example.com", password: "password123", password_confirmation: "password123")

    assert_no_difference("User.count") do
      post registration_url, params: {
        user: {
          email_address: existing_user.email_address,
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match(/ya existe esa cuenta, prueba con otro/, response.body)
  end
end
