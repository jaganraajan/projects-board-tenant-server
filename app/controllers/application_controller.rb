class ApplicationController < ActionController::API
  def health
    render json: { status: "ok" }
  end

  private

  def current_user
    @current_user ||= find_user_from_session || find_user_from_auth_header
  end

  def find_user_from_session
    # For development/testing - simple email parameter authentication
    if params[:email].present?
      User.find_by(email: params[:email])
    end
  end

  def find_user_from_auth_header
    # Token-based authentication for production use
    auth_header = request.headers['Authorization']
    return nil unless auth_header.present?

    # Extract token from "Bearer TOKEN" format
    token = auth_header.split(' ').last
    return nil unless token.present?

    # For now, decode token as base64 encoded email for simplicity
    # In production, you'd use JWT or similar
    begin
      email = Base64.decode64(token)
      User.find_by(email: email) if email.present?
    rescue
      nil
    end
  end

  def authenticate_user!
    unless current_user
      render json: { error: 'Authentication required' }, status: :unauthorized
    end
  end
end
