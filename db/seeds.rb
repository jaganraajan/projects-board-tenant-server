# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create test user for development
if Rails.env.development?
  user = User.find_or_create_by!(email: "test@example.com") do |u|
    u.password = "password123"
    u.company_name = "Test Company"
  end

  # Create some sample tasks
  Task.find_or_create_by!(title: "Fix critical production bug", user: user) do |t|
    t.description = "Database connection timeout affecting all users"
    t.status = "todo"
  end

  Task.find_or_create_by!(title: "Plan quarterly review meeting", user: user) do |t|
    t.description = "Schedule and prepare agenda for Q3 review"
    t.status = "todo"
  end

  Task.find_or_create_by!(title: "Update LinkedIn profile", user: user) do |t|
    t.description = "Add recent project accomplishments"
    t.status = "todo"
  end

  Task.find_or_create_by!(title: "Watch latest tech conference videos", user: user) do |t|
    t.description = "Catch up on React Summit presentations"
    t.status = "todo"
  end

  puts "Created test user and sample tasks for development"
end
