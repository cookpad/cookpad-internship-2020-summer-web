class SessionsController < ApplicationController
  def new
    @session_form = SessionCreateForm.new
  end

  def create
    @session_form = SessionCreateForm.new
    @session_form.apply(session_form_params)
    if @session_form.valid?
      sign_in_as(@session_form.identified_user)
      redirect_to root_path
    else
      render :new
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  private def session_form_params
    params.require(:session).permit(:name, :password)
  end
end
