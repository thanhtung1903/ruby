class PasswordResetsController < ApplicationController
  before_action :load_user, only: %I[edit update]
  before_action :valid_user, only: %I[edit update]
  before_action :check_expiration, only: %I[edit update]

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "controller.password_reset.create.info"
      redirect_to root_url
    else
      flash.now[:danger] = t "controller.password_reset.create.danger"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, :blank
    elsif @user.update_attributes user_params
      log_in @user
      @user.update_attributes reset_digest: nil
      flash[:success] = t "controller.password_reset.update.success"
      return redirect_to @user
    end
    render :edit
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  # valid_user method of before check find_by return nil so this method not need
  def load_user
    @user = User.find_by email: params[:email]
    return if @user
    flash[:danger] = t "controller.user.error_id"
    redirect_to root_path
  end

  # Confirms a valid user.
  def valid_user
    return if @user && @user.activated? && @user.authenticated?(:reset, params[:id])
    redirect_to root_url
  end

  # Checks expiration of reset token.
  def check_expiration
    return unless @user.password_reset_expired?
    flash[:danger] = t "controller.password_reset.check_expiration.danger"
    redirect_to new_password_reset_url
  end
end
