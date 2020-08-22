module IngredientsParser
  ParseError = Class.new(StandardError)
  TooLongError = Class.new(StandardError)

  module_function

  DELIMITER_REGEX = /[\t\s　]+/
  COLUMN_SIZE = 2

  # @param text [String]
  # @return [Array<Ingredient>]
  # @raise [ParseError] if text has invalid format
  def parse(text)
    parsed_lines = []
    text.each_line.with_index(1) do |line, lineno|
      striped_line = line.strip
      next if striped_line.blank?
      parsed_lines << [lineno, striped_line.split(DELIMITER_REGEX)]
    end

    ingredients = []
    parsed_lines.each_with_index do |(lineno, tokens), idx|
      if tokens.size == 1
        raise ParseError.new("line #{lineno} requires quantity.")
      elsif tokens.size > 2
        raise ParseError.new("line #{lineno} has too many columns.")
      end
      name, quantity = tokens
      if name.size > Ingredient::MAX_NAME_LENGTH
        raise TooLongError.new("line #{idx + 1} ingredient name is longer than #{Ingredient::MAX_NAME_LENGTH} chars.")
      end
      if quantity.size > Ingredient::MAX_QUANTITY_LENGTH
        raise TooLongError.new("line #{idx + 1} ingredient quantity is longer than #{Ingredient::MAX_QUANTITY_LENGTH} chars.")
      end

      ingredients << Ingredient.new(name: name, quantity: quantity, position: idx)
    end
    return ingredients
  end

  # @param ingredients [Array<Ingredient>]
  # @return [String]
  def encode(ingredients)
    ingredients.map { |ingredient| "#{ingredient.name} #{ingredient.quantity}" }.join("\n")
  end
end
