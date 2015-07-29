class Api::V1::SessionsController < ApplicationController
  def create
    user_email = params[:session][:email]
    user_password = params[:session][:password]
    user = user_email.present? && User.find_by(email: user_email)

    if user.valid_password? user_password
      sign_in user
      user.generate_authentication_token!
      user.save
      render json: user
    else
      render json: { errors: 'Invalid email or password' }, status: 422
    end
  end

  def destroy
    user = User.find_by(auth_token: params[:auth_token])
    user.generate_authentication_token!
    user.save
    head 204
  end
end
