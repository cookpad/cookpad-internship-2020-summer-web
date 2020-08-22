class UsersController < ApplicationController
  # GET /users
  def index
    @users = User.all
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  def new
    @user_form = UserCreateForm.new(User.new)
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    @user_form = UserUpdateForm.new(@user)
  end

  # POST /users
  def create
    @user_form = UserCreateForm.new(User.new)
    @user_form.apply(user_form_params)

    if @user_form.save
      redirect_to @user_form.user, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    @user = User.find(params[:id])
    @user_form = UserUpdateForm.new(@user)
    @user_form.apply(user_form_params)
    if @user_form.save
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private

  # Only allow a list of trusted parameters through.
  def user_form_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end
end
