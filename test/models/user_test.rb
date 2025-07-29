require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should create user with valid attributes" do
    user = User.new(
      email: "test@example.com",
      password: "password123",
      company_name: "Test Company"
    )
    assert user.save
  end

  test "should require email" do
    user = User.new(password: "password123", company_name: "Test Company")
    assert_not user.save
    assert_includes user.errors[:email], "can't be blank"
  end

  test "should require unique email" do
    User.create!(email: "test@example.com", password: "password123", company_name: "Test Company")
    user = User.new(email: "test@example.com", password: "password123", company_name: "Another Company")
    assert_not user.save
    assert_includes user.errors[:email], "has already been taken"
  end

  test "should require company_name" do
    user = User.new(email: "test@example.com", password: "password123")
    assert_not user.save
    assert_includes user.errors[:company_name], "can't be blank"
  end

  test "should authenticate with correct password" do
    user = User.create!(email: "test@example.com", password: "password123", company_name: "Test Company")
    assert user.authenticate("password123")
    assert_not user.authenticate("wrongpassword")
  end
end
