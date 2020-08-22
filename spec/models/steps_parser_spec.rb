RSpec.describe StepsParser, type: :model do
  describe '#parse' do
    let(:actual_steps) do
      StepsParser.parse(steps_text).map do |step|
        { description: step.description, position: step.position }
      end
    end

    context 'with valid text' do
      let(:steps_text) do
        <<~EOT
        step1
        step2
        EOT
      end

      it 'returns steps' do
        expected_steps = [
          { description: 'step1', position: 0 },
          { description: 'step2', position: 1 },
        ]
        expect(actual_steps).to eq(expected_steps)
      end
    end

    context 'with empty line' do
      let(:steps_text) do
        <<~EOT
        step1

        step2
        EOT
      end

      it 'ignores empty line' do
        expected_steps = [
          { description: 'step1', position: 0 },
          { description: 'step2', position: 1 },
        ]
        expect(actual_steps).to eq(expected_steps)
      end
    end

    context 'with too long description' do
      let(:steps_text) do
        's' * 256
      end

      it 'ignores empty line' do
        expect {
          actual_steps
        }.to raise_error(StepsParser::TooLongError, "line 1 is longer than 255 chars.")
      end
    end
  end

  describe '#dump' do
    let(:steps) do
      [
        Step.new(description: 'step1'),
        Step.new(description: 'step2'),
      ]
    end

    it 'returns steps_text' do
      expected_text = "step1\nstep2"
      expect(StepsParser.encode(steps)).to eq(expected_text)
    end
  end
end
