RSpec.describe Sbpayment::Crypto do
  let(:key)  { SecureRandom.hex 12 }
  let(:iv)   { SecureRandom.hex  4 }

  context 'when cipher_code and cipher_iv are not defined' do
    let(:data) { 'abcd' }

    it 'raises an error' do
      expect {
        Sbpayment::Crypto.encrypt(data)
      }.to raise_error ArgumentError
    end
  end

  context 'when cipher_code and cipher_iv are defined' do
    before do
      Sbpayment.configure do |x|
        x.cipher_code = key
        x.cipher_iv = iv
      end
    end

    describe 'encrypt' do
      let(:data) { 'abcd' }

      it 'can encrypt data' do
        expect(Sbpayment::Crypto.decrypt(Sbpayment::Crypto.encrypt(data))).to eq 'abcd'
      end
    end

    describe 'decrypt' do
      let(:data) { Sbpayment::Crypto.encrypt('abcd') }

      it 'can decrypt encrypted data' do
        expect(Sbpayment::Crypto.decrypt(data)).to eq 'abcd'
      end
    end
  end
end
