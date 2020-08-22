class SessionsController < ApplicationController
  def new
    @errors = []
  end

  def create
    @errors = []
    if params[:name].blank?
      @errors << "アカウント名を入力してください。"
    end
    if params[:password].blank?
      @errors << "パスワードを入力してください。"
    end
    if @errors.size > 0
      render :new
      return
    end

    user = User.find_by(name: params[:name])
    if user && DigestGenerator.validate(params[:password], user.password_digest)
      sign_in_as(user)
      redirect_to root_path
    else
      @errors << "アカウント名もしくはパスワードが違います。"
      render :new
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
