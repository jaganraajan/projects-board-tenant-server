class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: [:register, :login]

  # POST /register
  def register
    user = User.new(user_params)
    
    if user.save
      token = JWT.encode({ user_id: user.id }, Rails.application.secrets.secret_key_base)
      render json: { 
        token: token,
        id: user.id,
        email: user.email, 
        company_name: user.company_name 
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /login
  def login
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      token = JWT.encode({ user_id: user.id }, Rails.application.secrets.secret_key_base)
      render json: {
        token: token,
        id: user.id,
        email: user.email,
        company_name: user.company_name
      }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  # GET /me
  def me
    # Mock authentication by accepting email parameter
    if current_user
      render json: {
        id: current_user.id,
        email: current_user.email,
        company_name: current_user.company_name
      }
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :company_name)
  end

  def index
    render json: User.all
  end
end
