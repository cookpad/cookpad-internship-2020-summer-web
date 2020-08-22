RSpec.describe IngredientsParser, type: :model do
  describe '#parse' do
    let(:actual_ingredients) do
      IngredientsParser.parse(ingredients_text).map do |ingredient|
        { name: ingredient.name, quantity: ingredient.quantity, position: ingredient.position }
      end
    end

    context 'with valid text' do
      let(:ingredients_text) do
        <<~EOT
        ingredient1 10g

        ingredient2　1spoon
        EOT
      end

      it 'returns ingredients' do
        expected_ingredients = [
          { name: 'ingredient1', quantity: '10g', position: 0 },
          { name: 'ingredient2', quantity: '1spoon', position: 1 },
        ]
        expect(actual_ingredients).to eq(expected_ingredients)
      end
    end

    context 'with lack data' do
      let(:ingredients_text) do
        <<~EOT
        ingredient1 10g
        ingredient2
        EOT
      end

      it 'raises parse error with message' do
        expect {
          actual_ingredients
        }.to raise_error(IngredientsParser::ParseError, 'line 2 requires quantity.')
      end
    end

    context 'with too many data in column' do
      let(:ingredients_text) do
        <<~EOT
        ingredient1 10g
        ingredient2 1spoon extra_col
        EOT
      end

      it 'raises parse error with message' do
        expect {
          actual_ingredients
        }.to raise_error(IngredientsParser::ParseError, 'line 2 has too many columns.')
      end
    end

    context 'with long ingredient name' do
      let(:ingredients_text) do
        name = 'i' * 256
        "#{name} 10g"
      end

      it 'raises too long error with message' do
        expect {
          actual_ingredients
        }.to raise_error(IngredientsParser::TooLongError, 'line 1 ingredient name is longer than 255 chars.')
      end
    end

    context 'with long ingredient quantity' do
      let(:ingredients_text) do
        quantity = '1' * 256
        "ingredient1 #{quantity}"
      end

      it 'raises too long error with message' do
        expect {
          actual_ingredients
        }.to raise_error(IngredientsParser::TooLongError, 'line 1 ingredient quantity is longer than 255 chars.')
      end
    end
  end

  describe '#dump' do
    let(:ingredients) do
      [
        Ingredient.new(name: 'ingredient1', quantity: '10g'),
        Ingredient.new(name: 'ingredient2', quantity: '1spoon'),
      ]
    end

    it 'returns ingredients_text' do
      expected_text = "ingredient1 10g\ningredient2 1spoon"
      expect(IngredientsParser.encode(ingredients)).to eq(expected_text)
    end
  end
end
