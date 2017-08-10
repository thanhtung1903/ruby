class SessionsController < ApplicationController
  def new; end

  def create
    # instance variable to use  in test by assign
    @user = User.find_by email: params[:session][:email].downcase
    if @user && @user.authenticate(params[:session][:password]) # of h_s_p
      activate_or_not @user
    else
      flash.now[:danger] = t "controller.session.error"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def activate_or_not user
    if user.activated?
      log_in user # set session
      remember_or_not params[:session][:remember_me], user
      redirect_back_or user # check page need direct
    else
      flash[:warning] = t "controller.session.create.message"
      redirect_to root_url
    end
  end

  def remember_or_not checkbox_status, user
    checkbox_status == "1" ? remember(user) : forget(user)
  end
end
