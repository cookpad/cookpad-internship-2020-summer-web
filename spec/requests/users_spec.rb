RSpec.describe "/users", type: :request do
  describe "GET /index" do
    it "renders a successful response" do
      FactoryBot.create(:user)
      get users_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      user = FactoryBot.create(:user)
      get user_url(user)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_user_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      user = FactoryBot.create(:user)
      get edit_user_url(user)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:user_params) do
        { name: 'chef', password: 'password', password_confirmation: 'password' }
      end

      it "creates a new User" do
        expect {
          post users_url, params: { user: user_params }
        }.to change(User, :count).by(1)
      end

      it "redirects to the created user" do
        post users_url, params: { user: user_params }
        expect(response).to redirect_to(user_url(User.last))
      end
    end

    context "with invalid parameters" do
      let(:user_params) do
        { name: 'chef', password: 'password', password_confirmation: 'hohoho' }
      end

      it "does not create a new User" do
        expect {
          post users_url, params: { user: user_params }
        }.to change(User, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post users_url, params: { user: user_params }
        expect(response).to be_successful
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) do
        { name: 'next-chef' }
      end

      it "updates the requested user" do
        user = FactoryBot.create(:user, name: 'chef')
        patch user_url(user), params: { user: new_attributes }
        user.reload
        expect(user.name).to eq(new_attributes[:name])
      end

      it "redirects to the user" do
        user = FactoryBot.create(:user, name: 'chef')
        patch user_url(user), params: { user: new_attributes }
        user.reload
        expect(response).to redirect_to(user_url(user))
      end
    end

    context "with invalid parameters" do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        user = FactoryBot.create(:user)
        patch user_url(user), params: { user: { name: 'n' * 256 } }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested user" do
      user = FactoryBot.create(:user)
      expect {
        delete user_url(user)
      }.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      user = FactoryBot.create(:user)
      delete user_url(user)
      expect(response).to redirect_to(users_url)
    end
  end
end
