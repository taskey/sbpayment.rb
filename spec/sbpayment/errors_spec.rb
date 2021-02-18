RSpec.describe Sbpayment::Error do
  subject { Sbpayment::Error.superclass }
  it { is_expected.to equal(StandardError) }
end

RSpec.describe Sbpayment::APIError do
  subject(:defined_api_error) { Sbpayment::APIError.parse '10123203' }
  subject(:undefined_api_error) { Sbpayment::APIError.parse '11122333' }

  describe '.parse' do
    it 'parses a valid format to a related error' do
      expect(Sbpayment::APIError.parse '10123203').to be_an_instance_of(Sbpayment::API10123Error)
      expect(Sbpayment::APIError.parse '101K1203').to be_an_instance_of(Sbpayment::API101K1Error)
      expect(Sbpayment::APIError.parse '101T1999').to be_an_instance_of(Sbpayment::API101T1Error)
      expect(Sbpayment::APIError.parse '40530999').to be_an_instance_of(Sbpayment::API40530Error)
      expect(Sbpayment::APIError.parse '101ZZ203').to be_an_instance_of(Sbpayment::APIUnknown101Error)
      expect(Sbpayment::APIError.parse '11122333').to be_an_instance_of(Sbpayment::APIUnknownPaymentMethodError)
    end

    it 'raises an ArgumentError when given an invalid format' do
      expect { Sbpayment::APIError.parse '11122333\n' }.to raise_error(ArgumentError)
      expect { Sbpayment::APIError.parse '1112!333' }.to raise_error(ArgumentError)
      expect { Sbpayment::APIError.parse '111223339' }.to raise_error(ArgumentError)
      expect { Sbpayment::APIError.parse '1112299' }.to raise_error(ArgumentError)
    end

    context 'with common types' do
      context 'with unknown payment method' do
        subject { Sbpayment::APIError.parse '11105333' }

        it 'returns a APIUnknownCommonType05Error' do
          expect(subject).to be_an_instance_of(Sbpayment::APIUnknownCommonType05Error)
        end

        it 'knows the type detail' do
          expect(subject.type.summary).to eq('桁数エラー')
        end

        describe '#retryable?' do
          it 'returns boolean as the type' do
            expect(subject.retryable?).to eq(subject.type.retryable?)
          end
        end
      end

      context 'with known payment method' do
        subject { Sbpayment::APIError.parse '10105333' }

        it 'returns a API10105Error' do
          expect(subject).to be_an_instance_of(Sbpayment::API10105Error)
        end

        it 'knows the type detail' do
          expect(subject.type.summary).to eq('桁数エラー')
        end
      end
    end

    context 'with common items' do
      context 'with unknown payment method' do
        subject { Sbpayment::APIError.parse '11105999' }

        it 'returns a APIUnknownCommonType05Error' do
          expect(subject).to be_an_instance_of(Sbpayment::APIUnknownCommonType05Error)
        end

        it 'knows the item detail' do
          expect(subject.item.summary).to eq('該当項目なし')
        end
      end

      context 'with known payment method' do
        subject { Sbpayment::APIError.parse '10105999' }

        it 'returns a API10105Error' do
          expect(subject).to be_an_instance_of(Sbpayment::API10105Error)
        end

        it 'knows the item detail' do
          expect(subject.item.summary).to eq('該当項目なし')
        end
      end
    end

    context 'with a known pattern "40203200"' do
      subject { Sbpayment::APIError.parse '40203200' }

      it 'returns a API40203Error' do
        expect(subject).to be_an_instance_of(Sbpayment::API40203Error)
      end

      pending 'knows the item detail' do
        expect(subject.item.summary).to eq('取消対象年月')
      end
    end
  end

  describe '#payment_method' do
    subject { undefined_api_error.payment_method }
    it { is_expected.to be_an_instance_of(Sbpayment::APIError::PaymentMethod) }
  end

  describe '#type' do
    subject { undefined_api_error.type }
    it { is_expected.to be_an_instance_of(Sbpayment::APIError::Type) }
  end

  describe '#item' do
    subject { undefined_api_error.item }
    it { is_expected.to be_an_instance_of(Sbpayment::APIError::Item) }
  end

  describe '#res_err_code' do
    subject { undefined_api_error.res_err_code }
    it { is_expected.to eq('11122333') }
  end

  describe '#to_s' do
    subject { undefined_api_error.to_s }
    it { is_expected.to eq('11122333') }
  end

  describe '#summary' do
    context 'on a defined APIError' do
      it 'formats with code and summary' do
        expect(defined_api_error.summary.unicode_normalize).to eq('method: 101(クレジット), type: 23(クレジットカード使用不可), item: 203(分割回数)')
      end
    end

    context 'on an undefined APIError' do
      it 'formats with code and blank summary' do
        expect(undefined_api_error.summary).to eq('method: 111(), type: 22(), item: 333()')
      end
    end
  end

  describe '#inspect' do
    it 'contains summary' do
      expect(defined_api_error.inspect).to include(defined_api_error.summary)
    end
  end

  context 'on a defined APIError' do
    it 'has specific fields' do
      expect(defined_api_error.payment_method.code).to eq('101')
      expect(defined_api_error.payment_method.summary).to eq('クレジット')
      expect(defined_api_error.type.code).to eq('23')
      expect(defined_api_error.type.summary).to eq('クレジットカード使用不可')
      expect(defined_api_error.item.code).to eq('203')
      expect(defined_api_error.item.summary).to eq('分割回数')
    end
  end
end

RSpec.describe 'Specific API error' do
  it 'has ancestors as APIKnownError > API000Error > API00099Error' do
    expect(Sbpayment::API101Error.superclass).to equal(Sbpayment::APIKnownError)
    expect(Sbpayment::API10123Error.superclass).to equal(Sbpayment::API101Error)
  end
end

RSpec.describe Sbpayment::APIUnknownError do
  subject(:unknown_root) { Sbpayment::APIUnknownError }

  it 'is a subclass of Error' do
    expect(unknown_root.superclass).to equal(Sbpayment::Error)
  end

  it 'includes APIError' do
    expect(unknown_root).to be < Sbpayment::APIError
  end

  context Sbpayment::APIUnknownPaymentMethodError do
    subject { Sbpayment::APIUnknownPaymentMethodError }

    it 'is a subclass of APIUnknownError' do
      expect(subject.superclass).to equal(unknown_root)
    end
  end

  context 'on concrete subclasses' do
    subject(:payment_method_is_known) { Sbpayment::APIUnknown101Error }
    subject(:payment_method_is_unknown) { Sbpayment::APIUnknownPaymentMethodError }

    it 'is a subclass of related errors' do
      expect(payment_method_is_known.superclass).to equal(Sbpayment::APIUnknownErrorWithPaymentMethod)
      expect(payment_method_is_unknown.superclass).to equal(Sbpayment::APIUnknownError)
    end
  end
end

RSpec.describe Sbpayment::APIError::PaymentMethod do
  describe '.fetch' do
    subject { Sbpayment::APIError::PaymentMethod.fetch '405' }
    it { is_expected.to be_an_instance_of(Sbpayment::APIError::PaymentMethod) }

    it 'returns another instance when called with another code' do
      one = Sbpayment::APIError::PaymentMethod.fetch '405'
      another = Sbpayment::APIError::PaymentMethod.fetch '406'
      expect(another).not_to equal(one)
    end

    it 'returns the same instance when called with same code twice' do
      once = Sbpayment::APIError::PaymentMethod.fetch '405'
      twice = Sbpayment::APIError::PaymentMethod.fetch '405'
      expect(twice).to equal(once)
    end

    it 'raises an ArgumentError when given an invalid code' do
      expect { Sbpayment::APIError::PaymentMethod.fetch '4050' }.to raise_error(ArgumentError)
    end
  end
end

RSpec.describe Sbpayment::APIError::Type do
  describe '.fetch' do
    subject { Sbpayment::APIError::Type.fetch '40' }
    it { is_expected.to be_an_instance_of(Sbpayment::APIError::Type) }

    it 'returns another instance when called with another code' do
      one = Sbpayment::APIError::Type.fetch '40'
      another = Sbpayment::APIError::Type.fetch '41'
      expect(another).not_to equal(one)
    end

    it 'returns the same instance when called with same code twice' do
      once = Sbpayment::APIError::Type.fetch '40'
      twice = Sbpayment::APIError::Type.fetch '40'
      expect(twice).to equal(once)
    end

    it 'raises an ArgumentError when given an invalid code' do
      expect { Sbpayment::APIError::Type.fetch '405' }.to raise_error(ArgumentError)
    end
  end

  describe '#retryable?' do
    subject { type.retryable? }

    context 'on not a 8x/9x' do
      let!(:type) { Sbpayment::APIError::Type.fetch('26') }

      it { is_expected.to eq(false) }
    end

    context 'on a 8x' do
      let!(:type) { Sbpayment::APIError::Type.fetch('86') }

      it { is_expected.to eq(true) }
    end

    context 'on a 9x' do
      let!(:type) { Sbpayment::APIError::Type.fetch('96') }

      it { is_expected.to eq(true) }
    end
  end
end
