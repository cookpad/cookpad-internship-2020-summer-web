RSpec.describe RecipeForm, type: :model do
  describe '#validates' do
    let(:valid_params) do
      {
        title: 'Recipe',
        description: 'my favorite recipe',
        image: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/recipe.jpg'), 'image/jpeg'),
        steps_text: 'step1',
        ingredients_text: 'ingredient1 10g'
      }
    end
    let(:form) { RecipeForm.new(Recipe.new).tap { |f| f.apply(params) } }

    context 'with valid params' do
      let(:params) { valid_params }
      it { expect(form.valid?).to be true }
    end

    context 'with title absence' do
      let(:params) { valid_params.merge(title: nil) }
      it { expect(form.valid?).to be false }
    end

    context 'with too long title params' do
      let(:params) { valid_params.merge(title: 'n' * 256) }
      it { expect(form.valid?).to be false }
    end

    context 'with description absence' do
      let(:params) { valid_params.merge(description: nil) }
      it { expect(form.valid?).to be false }
    end

    context 'with too long description params' do
      let(:params) { valid_params.merge(description: 'p' * 513) }
      it { expect(form.valid?).to be false }
    end

    context 'with no image' do
      let(:params) { valid_params.merge(image: nil) }
      it { expect(form.valid?).to be true }
    end

    context 'with no step' do
      let(:params) { valid_params.merge(steps_text: '') }
      it { expect(form.valid?).to be false }
    end

    context 'with no ingredient' do
      let(:params) { valid_params.merge(ingredients_text: '') }
      it { expect(form.valid?).to be false }
    end

    context 'with invalid ingredient' do
      let(:params) { valid_params.merge(ingredients_text: 'hoge') }
      it { expect(form.valid?).to be false }
    end

    context 'with model' do
      let(:user) do
        FactoryBot.create(:user)
      end
      let(:image) do
        FactoryBot.create(:image)
      end
      let(:recipe) do
        FactoryBot.create(:recipe)
      end
      let(:form) { RecipeForm.new(recipe).tap { |f| f.apply(params) } }

      context 'without new image' do
        let(:params) { valid_params.merge(image: nil) }
        it 'skips image validation' do
          expect(form.valid?).to be true
        end
      end

      context 'with new image' do
        let(:params) { valid_params }
        it 'overrides image' do
          expect(form.valid?).to be true
        end
      end
    end
  end
end
