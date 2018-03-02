class UsersController < ApplicationController
  before_action :current_user, only: [:index, :show, :destroy, :to_section_1]
  def index
    @users = User.all
    if params[:email]
      @users = User.where(email: params[:email])
    end
  end

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      # Handle a successful update.
    else
      render 'edit'
    end
  end

  def complete_problem
    user = User.find(session[:user_id])
    user[:num_attempt] += 1
    user.save()
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to "/instructor_profile"
  end

  def move_to_section
    user = User.find(params[:id])
    user[:section] = params[:section]
    user.save()
    flash[:success] = "User updated"
    redirect_to "/instructor_profile"
  end

end
