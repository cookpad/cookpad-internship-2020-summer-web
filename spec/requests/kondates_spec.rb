RSpec.describe "/kondates", type: :request do
  describe "GET /index" do
    it "renders a successful response" do
      skip "to be implemented"
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      skip "to be implemented"
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      skip "to be implemented"
    end

    context 'without signed in' do
      it "redirects to sign in page" do
        skip "to be implemented"
      end
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      skip "to be implemented"
    end

    context 'without signed in' do
      it "redirects to sign in page" do
        skip "to be implemented"
      end
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Kondate" do
        skip "to be implemented"
      end

      it "redirects to the created kondate" do
        skip "to be implemented"
      end
    end

    context "with invalid parameters" do
      it "does not create a new Kondate" do
        skip "to be implemented"
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        skip "to be implemented"
      end
    end

    context 'without signed in' do
      it "redirects to sign in page" do
        skip "to be implemented"
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      it "updates the requested kondate" do
        skip "to be implemented"
      end

      it "redirects to the user" do
        skip "to be implemented"
      end
    end

    context "with invalid parameters" do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        skip "to be implemented"
      end
    end

    context 'without signed in' do
      it "redirects to sign in page" do
        skip "to be implemented"
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested kondate" do
      skip "to be implemented"
    end

    it "redirects to the users list" do
      skip "to be implemented"
    end

    context 'without signed in' do
      it "redirects to sign in page" do
        skip "to be implemented"
      end
    end
  end
end
