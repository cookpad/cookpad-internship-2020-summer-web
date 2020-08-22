RSpec.describe "/session", type: :request do
  let(:valid_password) { 'password' }
  let(:valid_password_digest) { DigestGenerator.digest(valid_password) }
  let(:valid_params) do
    { name: 'chef', password: valid_password }
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_session_url
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new User" do
        user = FactoryBot.create(:user, password_digest: valid_password_digest)
        post session_url, params: { name: user.name, password: valid_password }
        expect(request.session[:current_user_id]).to eq(user.id)
      end

      it "redirects to the logined user" do
        user = FactoryBot.create(:user, password_digest: valid_password_digest)
        post session_url, params: { name: user.name, password: valid_password }
        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid parameters" do
      it "renders a successful response (i.e. to display the 'new' template)" do
        post session_url, params: valid_params.merge(password: 'aaa')
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested user" do
      user = FactoryBot.create(:user)
      sign_in_as(user.name)
      delete session_url
      expect(response).to redirect_to(root_path)
    end
  end
end
