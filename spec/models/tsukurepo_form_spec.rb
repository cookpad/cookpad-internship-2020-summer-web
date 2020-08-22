RSpec.describe TsukurepoForm, type: :model do
  describe '#validates' do
    let(:valid_params) do
      {
        comment: 'thanks for your recipe!!',
        image: Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/recipe.jpg'), 'image/jpeg'),
      }
    end
    let(:form) { TsukurepoForm.new(Tsukurepo.new).tap { |f| f.apply(params) } }

    context 'with valid params' do
      let(:params) { valid_params }
      it { expect(form.valid?).to be true }
    end

    context 'with comment absence' do
      let(:params) { valid_params.merge(comment: nil) }
      it { expect(form.valid?).to be false }
    end

    context 'with too long comment params' do
      let(:params) { valid_params.merge(comment: 'n' * 256) }
      it { expect(form.valid?).to be false }
    end

    context 'with no image' do
      let(:params) { valid_params.merge(image: nil) }
      it { expect(form.valid?).to be true }
    end
  end
end
