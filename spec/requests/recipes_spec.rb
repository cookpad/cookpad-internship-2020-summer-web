RSpec.describe "/recipes", type: :request do
  let(:image) do
    FactoryBot.create(:image)
  end
  let(:user) do
    FactoryBot.create(:user)
  end

  describe "GET /index" do
    it "renders a successful response" do
      FactoryBot.create(:recipe)
      get recipes_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      recipe = FactoryBot.create(:recipe)
      get recipe_url(recipe)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      sign_in_as(user.name)
      get new_recipe_url
      expect(response).to be_successful
    end

    context 'without signed in' do
      it "redirects to sign in page" do
        get new_recipe_url
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      sign_in_as(user.name)
      recipe = FactoryBot.create(:recipe)
      get edit_recipe_url(recipe)
      expect(response).to be_successful
    end

    context 'without signed in' do
      it "redirects to sign in page" do
        recipe = FactoryBot.create(:recipe)
        get edit_recipe_url(recipe)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      let(:recipe_params) do
        {
          title: 'recipe1',
          description: 'recipe description1',
          image: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/recipe.jpg'), 'image/jpeg'),
          steps_text: 'step1',
          ingredients_text: 'ingredient1 10g'
        }
      end

      it "creates a new Recipe" do
        sign_in_as(user.name)
        expect {
          post recipes_url, params: { recipe: recipe_params }
        }.to change(Recipe, :count).by(1)
      end

      it "redirects to the created recipe" do
        sign_in_as(user.name)
        post recipes_url, params: { recipe: recipe_params }
        expect(response).to redirect_to(recipe_url(Recipe.last))
      end
    end

    context "with invalid parameters" do
      let(:recipe_params) do
        {
          title: 'r' * 256,
          description: 'recipe description1',
          steps_text: 'step1',
          ingredients_text: 'ingredient1 10g'
        }
      end

      it "does not create a new Recipe" do
        sign_in_as(user.name)
        expect {
          post recipes_url, params: { recipe: recipe_params }
        }.to change(Recipe, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        sign_in_as(user.name)
        post recipes_url, params: { recipe: recipe_params }
        expect(response).to be_successful
      end
    end

    context 'without signed in' do
      it "redirects to sign in page" do
        post recipes_url, params: { recipe: {} }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) do
        {
          title: 'recipe1',
          description: 'recipe description1',
          steps_text: 'step1',
          ingredients_text: 'ingredient1 10g'
        }
      end

      it "updates the requested recipe" do
        sign_in_as(user.name)
        recipe = FactoryBot.create(:recipe, title: 'old title')
        patch recipe_url(recipe), params: { recipe: new_attributes }
        recipe.reload
        expect(recipe.title).to eq(new_attributes[:title])
      end

      it "redirects to the user" do
        sign_in_as(user.name)
        recipe = FactoryBot.create(:recipe, title: 'old title')
        patch recipe_url(recipe), params: { recipe: new_attributes }
        recipe.reload
        expect(response).to redirect_to(recipe_url(recipe))
      end
    end

    context "with invalid parameters" do
      let(:new_attributes) do
        {
          title: 'n' * 256,
          description: 'recipe description1',
          steps_text: 'step1',
          ingredients_text: 'ingredient1 10g'
        }
      end

      it "renders a successful response (i.e. to display the 'edit' template)" do
        sign_in_as(user.name)
        recipe = FactoryBot.create(:recipe)
        patch recipe_url(recipe), params: { recipe: new_attributes }
        expect(response).to be_successful
      end
    end

    context 'without signed in' do
      it "redirects to sign in page" do
        recipe = FactoryBot.create(:recipe)
        patch recipe_url(recipe)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested recipe" do
      sign_in_as(user.name)
      recipe = FactoryBot.create(:recipe)
      expect {
        delete recipe_url(recipe)
      }.to change(Recipe, :count).by(-1)
    end

    it "redirects to the users list" do
      sign_in_as(user.name)
      recipe = FactoryBot.create(:recipe)
      delete recipe_url(recipe)
      expect(response).to redirect_to(recipes_url)
    end

    context 'without signed in' do
      it "redirects to sign in page" do
        recipe = FactoryBot.create(:recipe)
        delete recipe_url(recipe)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
