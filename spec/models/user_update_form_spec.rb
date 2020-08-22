RSpec.describe UserUpdateForm, type: :model do
  describe '#validates' do
    let(:valid_params) { { name: 'name', password: 'password', password_confirmation: 'password' } }
    let(:form) { UserUpdateForm.new.tap { |f| f.apply(params) } }

    context 'with valid params' do
      let(:params) { valid_params }
      it { expect(form.valid?).to be true }
    end

    context 'with name absence' do
      let(:params) { valid_params.merge(name: nil) }
      it { expect(form.valid?).to be false }
    end

    context 'with too long name params' do
      let(:params) { valid_params.merge(name: 'n' * 256) }
      it { expect(form.valid?).to be false }
    end

    context 'without password change' do
      let(:params) { valid_params.merge(password: nil, password_confirmation: nil) }
      it 'ignores password validation' do
        expect(form.valid?).to be true
      end
    end

    context 'with too long password params' do
      let(:params) { valid_params.merge(password: 'p' * 256) }
      it { expect(form.valid?).to be false }
    end

    context 'with password_confirmation absence' do
      let(:params) { valid_params.merge(password_confirmation: nil) }
      it { expect(form.valid?).to be false }
    end

    context 'with password != password_confirmation' do
      let(:params) { valid_params.merge(password: 'password', password_confirmation: 'wrongpass') }
      it { expect(form.valid?).to be false }
    end
  end
end
