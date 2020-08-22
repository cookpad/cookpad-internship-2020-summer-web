RSpec.describe "/tsukurepos", type: :request do
  let(:image) do
    FactoryBot.create(:image)
  end
  let(:user) do
    FactoryBot.create(:user)
  end
  let(:recipe_author) do
    FactoryBot.create(:user)
  end
  let(:recipe) do
    FactoryBot.create(:recipe)
  end

  describe "GET /new" do
    context "with recipe_id" do
      it "renders a successful response" do
        sign_in_as(user.name)
        get new_recipe_tsukurepo_url(recipe)
        expect(response).to be_successful
      end
    end

    context 'without signed in' do
      it "redirects to sign in page" do
        get new_recipe_tsukurepo_url(recipe)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:tsukurepo_params) do
        {
          comment: 'thanks for your recipe!!',
          image: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/recipe.jpg'), 'image/jpeg'),
        }
      end

      it "creates a new Tsukurepo" do
        sign_in_as(user.name)
        expect {
          post recipe_tsukurepos_url(recipe), params: { tsukurepo: tsukurepo_params }
        }.to change(Tsukurepo, :count).by(1)
      end

      it "redirects to the created tsukurepo" do
        sign_in_as(user.name)
        post recipe_tsukurepos_url(recipe), params: { tsukurepo: tsukurepo_params }
        expect(response).to redirect_to(recipe_url(recipe))
      end
    end

    context "with invalid parameters" do
      let(:tsukurepo_params) do
        { comment: 'r' * 256 }
      end

      it "does not create a new Tsukurepo" do
        sign_in_as(user.name)
        expect {
          post recipe_tsukurepos_url(recipe), params: { tsukurepo: tsukurepo_params }
        }.to change(Tsukurepo, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        sign_in_as(user.name)
        post recipe_tsukurepos_url(recipe), params: { tsukurepo: tsukurepo_params }
        expect(response).to be_successful
      end
    end

    context 'without signed in' do
      it "redirects to sign in page" do
        post recipe_tsukurepos_url(recipe), params: { tsukurepo: {} }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested tsukurepo" do
      sign_in_as(user.name)
      tsukurepo = FactoryBot.create(:tsukurepo)
      recipe = tsukurepo.recipe
      expect {
        delete recipe_tsukurepo_url(recipe, tsukurepo)
      }.to change(Tsukurepo, :count).by(-1)
    end

    it "redirects to the users list" do
      sign_in_as(user.name)
      tsukurepo = FactoryBot.create(:tsukurepo)
      recipe = tsukurepo.recipe
      delete recipe_tsukurepo_url(recipe, tsukurepo)
      expect(response).to redirect_to(recipe_path(recipe))
    end

    context 'without signed in' do
      it "redirects to sign in page" do
        tsukurepo = FactoryBot.create(:tsukurepo)
        recipe = tsukurepo.recipe
        delete recipe_tsukurepo_url(recipe, tsukurepo)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
