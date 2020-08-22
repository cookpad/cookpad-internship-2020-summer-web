RSpec.describe "/top", type: :request do
  describe "GET /index" do
    it "renders a successful response" do
      FactoryBot.create(:recipe)
      FactoryBot.create(:tsukurepo)

      get root_url
      expect(response).to be_successful
    end
  end
end
