class ApplicationController < ActionController::API
  def health
    render json: { status: "ok" }
  end

  private

  # Authentication helper following the existing pattern
  def current_user
    return @current_user if defined?(@current_user)
    
    email = params[:email] || request.headers['X-User-Email']
    @current_user = email.present? ? User.find_by(email: email) : nil
  end

  def authenticate_user!
    unless current_user
      render json: { error: 'Authentication required. Provide email parameter or X-User-Email header.' }, 
             status: :unauthorized
    end
  end

  def authorize_task_access!(task)
    unless task.user == current_user
      render json: { error: 'You can only access your own tasks.' }, 
             status: :forbidden
    end
  end
end
