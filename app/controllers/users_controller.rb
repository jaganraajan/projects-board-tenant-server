class UsersController < ApplicationController
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
    email = params[:email]
    
    if email.blank?
      render json: { error: 'Email parameter is required' }, status: :bad_request
      return
    end
    
    user = User.find_by(email: email)
    
    if user
      render json: { 
        email: user.email, 
        company_name: user.company_name 
      }
    else
      render json: { error: 'User not found' }, status: :not_found
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
