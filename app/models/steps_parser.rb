module StepsParser
  TooLongError = Class.new(StandardError)

  module_function

  # @param text [String]
  # @return [Array<Step>]
  def parse(text)
    parsed_lines = text.each_line.map(&:strip).reject(&:blank?)
    parsed_lines.map.with_index do |description, idx|
      if description.size < Step::MAX_DESCRIPTION_LENGTH
        Step.new(description: description, position: idx)
      else
        raise TooLongError.new("line #{idx + 1} is longer than #{Step::MAX_DESCRIPTION_LENGTH} chars.")
      end
    end
  end

  # @param steps [Array<Step>]
  # @return [String]
  def encode(steps)
    steps.map(&:description).join("\n")
  end
end
