require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "taskuser@example.com",
      password: "password123",
      company_name: "Task Company"
    )
    @other_user = User.create!(
      email: "otheruser@example.com", 
      password: "password123",
      company_name: "Other Company"
    )
    @task = @user.tasks.create!(
      title: "Test Task",
      description: "Test description",
      status: "todo"
    )
    @other_task = @other_user.tasks.create!(
      title: "Other Task",
      description: "Other description", 
      status: "in_progress"
    )
  end

  test "should require authentication for index" do
    get "/tasks"
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "Authentication required", json_response["error"]
  end

  test "should get tasks for authenticated user" do
    get "/tasks", params: { email: @user.email }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.length
    assert_equal @task.title, json_response.first["title"]
    assert_equal @task.id, json_response.first["id"]
  end

  test "should not see other users tasks" do
    get "/tasks", params: { email: @user.email }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    task_ids = json_response.map { |task| task["id"] }
    assert_not_includes task_ids, @other_task.id
  end

  test "should create task for authenticated user" do
    task_params = {
      task: {
        title: "New Task",
        description: "New description",
        status: "todo"
      }
    }

    assert_difference '@user.tasks.count', 1 do
      post "/tasks", params: task_params.merge(email: @user.email)
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "New Task", json_response["title"]
    assert_equal "New description", json_response["description"]
    assert_equal "todo", json_response["status"]
    assert_equal @user.id, json_response["user_id"]
  end

  test "should require authentication for create" do
    task_params = {
      task: {
        title: "New Task",
        description: "New description", 
        status: "todo"
      }
    }

    post "/tasks", params: task_params
    assert_response :unauthorized
  end

  test "should validate task params on create" do
    task_params = {
      task: {
        title: "",
        description: "Description without title",
        status: "invalid_status"
      }
    }

    post "/tasks", params: task_params.merge(email: @user.email)
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Title can't be blank"
    assert_includes json_response["errors"], "Status is not included in the list"
  end

  test "should show task for owner" do
    get "/tasks/#{@task.id}", params: { email: @user.email }
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal @task.title, json_response["title"]
    assert_equal @task.id, json_response["id"]
  end

  test "should not show task for non-owner" do
    get "/tasks/#{@task.id}", params: { email: @other_user.email }
    assert_response :not_found
  end

  test "should update task for owner" do
    task_params = {
      task: {
        title: "Updated Task",
        status: "in_progress"
      }
    }

    patch "/tasks/#{@task.id}", params: task_params.merge(email: @user.email)
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal "Updated Task", json_response["title"]
    assert_equal "in_progress", json_response["status"]
    
    @task.reload
    assert_equal "Updated Task", @task.title
    assert_equal "in_progress", @task.status
  end

  test "should not update task for non-owner" do
    task_params = {
      task: {
        title: "Hacked Task"
      }
    }

    patch "/tasks/#{@task.id}", params: task_params.merge(email: @other_user.email)
    assert_response :not_found
  end

  test "should validate task params on update" do
    task_params = {
      task: {
        status: "invalid_status"
      }
    }

    patch "/tasks/#{@task.id}", params: task_params.merge(email: @user.email)
    assert_response :unprocessable_entity
    
    json_response = JSON.parse(response.body)
    assert_includes json_response["errors"], "Status is not included in the list"
  end

  test "should delete task for owner" do
    assert_difference '@user.tasks.count', -1 do
      delete "/tasks/#{@task.id}", params: { email: @user.email }
    end
    
    assert_response :no_content
    assert_empty response.body
  end

  test "should not delete task for non-owner" do
    assert_no_difference '@other_user.tasks.count' do
      delete "/tasks/#{@task.id}", params: { email: @other_user.email }
    end
    
    assert_response :not_found
  end

  test "should require authentication for all endpoints" do
    # Test each endpoint without authentication
    get "/tasks"
    assert_response :unauthorized

    post "/tasks", params: { task: { title: "Test" } }
    assert_response :unauthorized

    get "/tasks/#{@task.id}"
    assert_response :unauthorized

    patch "/tasks/#{@task.id}", params: { task: { title: "Test" } }
    assert_response :unauthorized

    delete "/tasks/#{@task.id}"
    assert_response :unauthorized
  end

  test "should support token-based authentication" do
    # Test with Authorization header (Base64 encoded email)
    token = Base64.encode64(@user.email)
    headers = { 'Authorization' => "Bearer #{token}" }

    get "/tasks", headers: headers
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert_equal 1, json_response.length
    assert_equal @task.title, json_response.first["title"]
  end
end
