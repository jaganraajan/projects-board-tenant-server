require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should register new user" do
    post "/register", params: {
      user: {
        email: "newuser@example.com",
        password: "password123",
        company_name: "New Company"
      }
    }
    
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "newuser@example.com", json_response["email"]
    assert_equal "New Company", json_response["company_name"]
    assert json_response["id"]
    assert_not json_response.key?("password_digest")
  end

  test "should return errors for invalid registration" do
    post "/register", params: {
      user: {
        email: "invalid-email",
        password: "",
        company_name: ""
      }
    }
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["errors"]
    assert_includes json_response["errors"], "Email is invalid"
    assert_includes json_response["errors"], "Password can't be blank"
    assert_includes json_response["errors"], "Company name can't be blank"
  end

  test "should get user info with valid email" do
    user = User.create!(email: "existing@example.com", password: "password123", company_name: "Existing Company")
    
    get "/me", params: { email: "existing@example.com" }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "existing@example.com", json_response["email"]
    assert_equal "Existing Company", json_response["company_name"]
    assert_not json_response.key?("password_digest")
  end

  test "should return error for missing email parameter" do
    get "/me"
    
    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Email parameter is required", json_response["error"]
  end

  test "should return error for non-existent user" do
    get "/me", params: { email: "nonexistent@example.com" }
    
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "User not found", json_response["error"]
  end
end
