class DummySessionsController < ActionController::Base
  def create
    user = User.find_by!(name: params[:name])
    session[:current_user_id] = user.id
  end
end

Rails.application.routes.append do
  resource :dummy_session, only: :create
end
Rails.application.routes_reloader.reload!

module SignInAs
  def sign_in_as(name)
    post dummy_session_url, params: { name: name }
  end
end

RSpec.configure do |config|
  config.include SignInAs, type: :request
end
