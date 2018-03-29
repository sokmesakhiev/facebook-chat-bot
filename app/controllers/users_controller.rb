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
    params = convert_role_params
    @user = User.find(params[:id])

    authorize @user

    if @user.update_attributes!(filter_params)
      redirect_to accounts_path, notice: 'Account has been updated successfully'
    else
      flash.now[:alert] = 'Failed to update user'
      render :new
    end
  end

  def create
    params = convert_role_params
    @user = User.new(filter_params)

    authorize @user

    @User.password = params[:account][:password]
    @User.password_confirmation = params[:account][:password_confirmation]
    if @User.valid?
      if @User.save!
        redirect_to accounts_path, notice: 'Account has been created successfully'
      else
        flash.now[:alert] = 'Failed to save user'
        render :new
      end
    else
      flash.now[:alert] = 'Failed to save user'
      render :new, errors: @User.errors
    end
  end

  def destroy
    @user = User.find(params[:id])

    authorize @user

    if @User.destroy!
      redirect_to accounts_path, notice: 'Account has been deleted'
    else
      redirect_to accounts_path, notice: 'Could not delete account user'
    end
  end

  private

  def filter_params
    params.require(:account).permit(:email, :password, :password_confirmation, :is_admin, :is_counsellor, schools: [])
  end

  def convert_role_params
    if params[:account][:role] == Account::ROLE[0]
      params[:account][:is_admin] = true
      params[:account][:schools] = nil
    else
      params[:account][:is_counsellor] = true
      params[:account][:schools] = [params[:account][:schools]]
    end
    params[:account].delete(:role)
    params
  end
end
