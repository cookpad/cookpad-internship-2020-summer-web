module Authenticatable
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :signed_in?
  end

  private def require_signed_in
    if current_user.nil?
      redirect_to new_session_path, notice: 'You need to login'
    end
  end

  private def current_user
    @current_user ||= User.find_by(id: session[:current_user_id])
  end

  private def signed_in?
    current_user.present?
  end

  private def sign_in_as(user)
    session[:current_user_id] = user.id
  end

  private def sign_out
    session.delete(:current_user_id)
  end
end
