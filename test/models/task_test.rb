require "test_helper"

class TaskTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "taskuser@example.com",
      password: "password123", 
      company_name: "Test Company"
    )
  end

  test "should create valid task" do
    task = @user.tasks.build(
      title: "Test Task",
      description: "Test description",
      status: "todo"
    )
    
    assert task.valid?
    assert task.save
  end

  test "should require title" do
    task = @user.tasks.build(
      description: "Test description",
      status: "todo"
    )
    
    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "should require status" do
    task = @user.tasks.build(
      title: "Test Task",
      description: "Test description"
    )
    
    assert_not task.valid?
    assert_includes task.errors[:status], "can't be blank"
  end

  test "should validate status values" do
    valid_statuses = %w[todo in_progress done]
    
    valid_statuses.each do |status|
      task = @user.tasks.build(
        title: "Test Task",
        status: status
      )
      assert task.valid?, "#{status} should be a valid status"
    end

    invalid_task = @user.tasks.build(
      title: "Test Task", 
      status: "invalid_status"
    )
    assert_not invalid_task.valid?
    assert_includes invalid_task.errors[:status], "is not included in the list"
  end

  test "should require user" do
    task = Task.new(
      title: "Test Task",
      status: "todo"
    )
    
    assert_not task.valid?
    assert_includes task.errors[:user], "must exist"
  end

  test "should belong to user" do
    task = @user.tasks.create!(
      title: "Test Task",
      status: "todo"
    )
    
    assert_equal @user, task.user
    assert_includes @user.tasks, task
  end

  test "should allow empty description" do
    task = @user.tasks.build(
      title: "Test Task",
      status: "todo"
    )
    
    assert task.valid?
    assert_nil task.description
  end
end
