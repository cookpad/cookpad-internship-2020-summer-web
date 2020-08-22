RSpec.describe SessionCreateForm, type: :model do
  describe '#validates' do
    let(:valid_password) { 'password' }
    let(:valid_params) { { name: user.name, password: valid_password } }
    let(:user) { FactoryBot.create(:user, password_digest: DigestGenerator.digest(valid_password)) }
    let(:form) { SessionCreateForm.new.tap { |f| f.apply(params) } }

    context 'with valid params' do
      let(:params) { valid_params }
      it { expect(form.valid?).to be true }
    end

    context 'with name absence' do
      let(:params) { valid_params.merge(name: nil) }
      it { expect(form.valid?).to be false }
    end

    context 'with password absence' do
      let(:params) { valid_params.merge(password: nil) }
      it { expect(form.valid?).to be false }
    end

    context 'with invalid password' do
      let(:params) { valid_params.merge(password: valid_password + '1') }
      it { expect(form.valid?).to be false }
    end
  end
end
