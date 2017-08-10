class UsersController < ApplicationController
  before_action :load_user, except: %I[new index create]
  before_action :logged_in_user,
    only: %I[index edit update destroy following followers] # an array of symbol
  before_action :correct_user, only: %I[edit update] # only edit their infor
  before_action :admin_user, only: :destroy

  def index
    @users = User.select_user_activated.paginate page: params[:page], :per_page => 10
  end

  def show
    @microposts = @user.microposts.paginate page: params[:page], :per_page => 5
    return if @user.activated?
    flash[:danger] = t "controller.user.error_activate"
    redirect_to root_path
  end

  def new
    @user = User.new
  end

  def create # post
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "controller.user.create.info"
      redirect_to root_url
    else
      render :new # haven't a view for create action, so must render new view
    end
  end

  def edit; end

  def update # patch
    if @user.update_attributes user_params
      flash[:success] = t "controller.user.updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "controller.user.destroy.success"
      redirect_to users_url
    else
      flash[:danger] = t "controller.user.destroy.danger"
      redirect_to root_url
    end
  end

  def following
    @title = t "controller.user.following.title"
    @user = User.find_by id: params[:id]
    if @user
      @users = @user.following.paginate page: params[:page], :per_page => 10
      render "show_follow"
    else
      redirect_to root_url
    end
  end

  def followers
    @title = t "controller.user.followers.title"
    @user = User.find_by id: params[:id]
    if @user
      @users = @user.followers.paginate page: params[:page], :per_page => 10
      render "show_follow"
    else
      redirect_to root_url
    end
  end

  private

  def user_params
    params.require(:user).permit :name, :email, :password,
      :password_confirmation
  end

  def load_user
    @user = User.find_by id: params[:id] # request to other user
    return if @user
    flash[:danger] = t "controller.user.error_id"
    redirect_to root_path
  end
end
