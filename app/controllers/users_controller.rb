# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.all
    authorize @users
  end

  def create
    @user = User.new(data_params)
    authorize @user

    if @user.save
      redirect_to users_path, notice: 'User created successfully!'
    else
      redirect_to users_path, alert: @user.errors.full_messages
    end
  end

  def update
    @user = User.find(params[:id])
    authorize @user

    if @user.update_attributes(data_params)
      redirect_to users_path, notice: 'User updated successfully!'
    else
      redirect_to users_path, alert: @user.errors.full_messages
    end
  end

  def destroy
    @user = User.find(params[:id])
    authorize @user

    if @user.destroy
      redirect_to users_path, notice: 'User deleted successfully!'
    else
      redirect_to users_path, alert: @user.errors.full_messages
    end
  end

  private

  def data_params
    param = params.require(:user).permit(:email, :role)
    param[:name] = param[:email].split('@').first
    param
  end
end
