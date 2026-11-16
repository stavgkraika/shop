require "test_helper"

class RegistrationsTest < ActionDispatch::IntegrationTest
  test "registers a user with a name" do
    assert_difference("User.count", 1) do
      post user_registration_path, params: {
        user: {
          name: "Test Seller",
          email: "seller@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    user = User.find_by!(email: "seller@example.com")
    assert_equal "Test Seller", user.name
    assert_response :redirect
  end
    test "updates the account with the correct current password" do
    user = User.create!(
      name: "Original Name",
      email: "update@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post user_session_path, params: {
      user: { email: user.email, password: "password123" }
    }

    put user_registration_path, params: {
      user: {
        name: "Updated Name",
        email: user.email,
        current_password: "password123"
      }
    }

    assert_equal "Updated Name", user.reload.name
    assert_response :redirect
  end

  test "does not update the account with an incorrect current password" do
    user = User.create!(
      name: "Original Name",
      email: "wrong-password@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    post user_session_path, params: {
      user: { email: user.email, password: "password123" }
    }

    put user_registration_path, params: {
      user: {
        name: "Updated Name",
        email: user.email,
        current_password: "wrong-password"
      }
    }

    assert_equal "Original Name", user.reload.name
  end
    test "changes the password with the correct current password" do
    user = User.create!(
      name: "Test Seller",
      email: "password-change@example.com",
      password: "oldpassword123",
      password_confirmation: "oldpassword123"
    )

    post user_session_path, params: {
      user: { email: user.email, password: "oldpassword123" }
    }

    put user_registration_path, params: {
      user: {
        name: user.name,
        email: user.email,
        password: "newpassword123",
        password_confirmation: "newpassword123",
        current_password: "oldpassword123"
      }
    }

    user.reload
    assert user.valid_password?("newpassword123")
    assert_not user.valid_password?("oldpassword123")
    assert_response :redirect
  end
end