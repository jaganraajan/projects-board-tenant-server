require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user1 = users(:one)
    @user2 = users(:two)
    @task1 = tasks(:one)  # belongs to user1
    @task2 = tasks(:two)  # belongs to user1
    @task3 = tasks(:three)  # belongs to user2
  end

  # Test authentication
  test "should require authentication for all actions" do
    get "/tasks"
    assert_response :unauthorized
    
    post "/tasks", params: { task: { title: "Test", status: "todo" } }
    assert_response :unauthorized
    
    patch "/tasks/#{@task1.id}", params: { task: { status: "done" } }
    assert_response :unauthorized
    
    delete "/tasks/#{@task1.id}"
    assert_response :unauthorized
  end

  # Test index
  test "should get index of current user's tasks" do
    get "/tasks", params: { email: @user1.email }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 2, json_response.length
    task_titles = json_response.map { |t| t["title"] }
    assert_includes task_titles, "Fix login bug"
    assert_includes task_titles, "Update documentation"
    assert_not_includes task_titles, "Design homepage"  # belongs to user2
  end

  test "should get empty index for user with no tasks" do
    # Create user with no tasks
    user = User.create!(email: "notasks@example.com", password: "password123", company_name: "No Tasks Co")
    
    get "/tasks", params: { email: user.email }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 0, json_response.length
  end

  # Test show
  test "should show task belonging to current user" do
    get "/tasks/#{@task1.id}", params: { email: @user1.email }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @task1.title, json_response["title"]
    assert_equal @task1.status, json_response["status"]
    assert_equal @task1.id, json_response["id"]
  end

  test "should not show task belonging to other user" do
    get "/tasks/#{@task3.id}", params: { email: @user1.email }
    
    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal "You can only access your own tasks.", json_response["error"]
  end

  test "should return not found for non-existent task" do
    get "/tasks/999999", params: { email: @user1.email }
    
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Task not found", json_response["error"]
  end

  # Test create
  test "should create task for authenticated user" do
    assert_difference('Task.count') do
      post "/tasks", params: {
        email: @user1.email,
        task: {
          title: "New task",
          description: "This is a new task",
          status: "todo"
        }
      }
    end
    
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "New task", json_response["title"]
    assert_equal "This is a new task", json_response["description"]
    assert_equal "todo", json_response["status"]
    assert_equal @user1.id, json_response["user_id"]
  end

  test "should validate required fields when creating task" do
    assert_no_difference('Task.count') do
      post "/tasks", params: {
        email: @user1.email,
        task: {
          description: "Missing title and status"
        }
      }
    end
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Title can't be blank"
    assert_includes json_response["errors"], "Status can't be blank"
  end

  test "should validate status when creating task" do
    assert_no_difference('Task.count') do
      post "/tasks", params: {
        email: @user1.email,
        task: {
          title: "Test task",
          status: "invalid_status"
        }
      }
    end
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Status is not included in the list"
  end

  # Test update
  test "should update own task" do
    patch "/tasks/#{@task1.id}", params: {
      email: @user1.email,
      task: {
        status: "done",
        title: "Updated title"
      }
    }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "done", json_response["status"]
    assert_equal "Updated title", json_response["title"]
    
    @task1.reload
    assert_equal "done", @task1.status
    assert_equal "Updated title", @task1.title
  end

  test "should not update task belonging to other user" do
    patch "/tasks/#{@task3.id}", params: {
      email: @user1.email,
      task: {
        status: "done"
      }
    }
    
    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal "You can only access your own tasks.", json_response["error"]
  end

  test "should validate status when updating task" do
    patch "/tasks/#{@task1.id}", params: {
      email: @user1.email,
      task: {
        status: "invalid_status"
      }
    }
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Status is not included in the list"
  end

  # Test destroy
  test "should delete own task" do
    assert_difference('Task.count', -1) do
      delete "/tasks/#{@task1.id}", params: { email: @user1.email }
    end
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Task deleted successfully", json_response["message"]
  end

  test "should not delete task belonging to other user" do
    assert_no_difference('Task.count') do
      delete "/tasks/#{@task3.id}", params: { email: @user1.email }
    end
    
    assert_response :forbidden
    json_response = JSON.parse(response.body)
    assert_equal "You can only access your own tasks.", json_response["error"]
  end

  test "should return not found when deleting non-existent task" do
    delete "/tasks/999999", params: { email: @user1.email }
    
    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Task not found", json_response["error"]
  end

  # Test authentication with header
  test "should authenticate with X-User-Email header" do
    get "/tasks", headers: { 'X-User-Email' => @user1.email }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 2, json_response.length
  end

  test "should prioritize email parameter over header" do
    get "/tasks", 
        params: { email: @user1.email }, 
        headers: { 'X-User-Email' => @user2.email }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal 2, json_response.length  # user1 has 2 tasks
  end

  # Test priority classification
  test "should assign priority when creating task without OpenAI API key" do
    # Test fallback behavior when no API key is set
    assert_difference('Task.count') do
      post "/tasks", params: {
        email: @user1.email,
        task: {
          title: "Urgent bug fix needed",
          description: "Critical production issue",
          status: "todo"
        }
      }
    end
    
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "Urgent bug fix needed", json_response["title"]
    assert_equal "Priority 2", json_response["priority"]  # fallback priority
    assert json_response.key?("priority")
  end

  test "should include priority in task response" do
    # Create a task with priority manually to test response format
    task = @user1.tasks.create!(
      title: "Test task", 
      status: "todo", 
      priority: "Priority 1"
    )
    
    get "/tasks/#{task.id}", params: { email: @user1.email }
    
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Priority 1", json_response["priority"]
    assert json_response.key?("priority")
  end

  test "should validate priority values" do
    assert_no_difference('Task.count') do
      post "/tasks", params: {
        email: @user1.email,
        task: {
          title: "Test task",
          status: "todo",
          priority: "Invalid Priority"
        }
      }
    end
    
    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Priority is not included in the list"
  end

  test "should allow manual priority override" do
    assert_difference('Task.count') do
      post "/tasks", params: {
        email: @user1.email,
        task: {
          title: "Manual priority task",
          description: "This should be overridden",
          status: "todo",
          priority: "Priority 3"
        }
      }
    end
    
    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "Priority 3", json_response["priority"]
  end
end