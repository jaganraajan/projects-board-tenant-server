class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [:show, :update, :destroy]
  before_action :check_task_authorization, only: [:show, :update, :destroy]

  # GET /tasks
  def index
    @tasks = current_user.tasks.includes(:user)
    render json: @tasks.map { |task| task_json(task) }
  end

  # GET /tasks/:id
  def show
    render json: task_json(@task)
  end

  # POST /tasks
  def create
    @task = current_user.tasks.build(task_params)
    
    if @task.save
      render json: task_json(@task), status: :created
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /tasks/:id
  def update
    if @task.update(task_update_params)
      render json: task_json(@task)
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /tasks/:id
  def destroy
    @task.destroy
    render json: { message: 'Task deleted successfully' }, status: :ok
  end

  private

  def set_task
    @task = Task.find_by(id: params[:id])
    unless @task
      render json: { error: 'Task not found' }, status: :not_found
    end
  end

  def check_task_authorization
    return unless @task
    authorize_task_access!(@task)
  end

  def task_params
    params.require(:task).permit(:title, :description, :status)
  end

  def task_update_params
    params.require(:task).permit(:title, :description, :status)
  end

  def task_json(task)
    {
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      user_id: task.user_id,
      created_at: task.created_at,
      updated_at: task.updated_at
    }
  end
end