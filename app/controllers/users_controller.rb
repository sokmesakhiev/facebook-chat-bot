# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    @users = User.all

    authorize @users
  end

  def show
    @user = User.find(params[:id])

    authorize @user
  end

  def new
    @user = User.new

    authorize @user
  end

  def edit
    @user = User.find(params[:id])

    authorize @user
  end

  def update
    @user = User.find(params[:id])

    authorize @user

    if @user.update_attributes!(data_params)
      redirect_to users_path, notice: 'User has been updated successfully'
    else
      flash.now[:alert] = 'Failed to update user'
      render :new
    end
  end

  def create
    @user = User.new(data_params)
    authorize @user

    if !@user.valid?
      flash.now[:alert] = 'Failed to save user'
      render :new, errors: @user.errors
    end

    if @user.save!
      redirect_to users_path, notice: 'User has been created successfully'
    else
      flash.now[:alert] = 'Failed to save user'
      render :new
    end
  end

  def destroy
    @user = User.find(params[:id])

    authorize @user

    if @user.destroy!
      redirect_to users_path, notice: 'User has been deleted'
    else
      redirect_to users_path, notice: 'Could not delete user'
    end
  end

  private

  def data_params
    params.require(:user).permit(:email, :password, :password_confirmation, :role)
  end
end
