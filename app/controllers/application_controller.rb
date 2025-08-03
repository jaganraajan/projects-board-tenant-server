class ApplicationController < ActionController::API
    before_action :authenticate_request

  def health
    render json: { status: "ok" }
  end

  private

  def authenticate_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    begin
      decoded = JWT.decode(header, Rails.application.secrets.secret_key_base)[0]
      @current_user = User.find(decoded["user_id"])
    rescue
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

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
