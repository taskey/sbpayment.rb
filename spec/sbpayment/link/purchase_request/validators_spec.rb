# coding: Shift_JIS

describe Sbpayment::Link::PurchaseRequest::FREE_CSV_FIELD_VALIDATOR do
  subject { described_class }

  describe '.valid?' do
    context 'when given a valid string' do
      it { is_expected.to be_valid('valid+valid@example.com') }
    end

    context 'when given an invalid string' do
      it { is_expected.not_to be_valid('valid,valid@example.com') }
    end
  end
end

describe Sbpayment::Link::PurchaseRequest::FREE_CSV_EMAIL_VALIDATOR do
  subject { described_class }

  describe '.valid?' do
    context 'when given a valid string' do
      it { is_expected.to be_valid('valid_valid@example.com') }
    end

    context 'when given an invalid string' do
      it { is_expected.not_to be_valid('valid+valid@example.com') }
    end
  end
end
