RSpec.describe Sbpayment::CallbackFactory do
  let(:request_header) { nil }

  describe 'PayEasy Notice' do
    let(:notice_body) { File.open("spec/fixtures/payeasy_notice_request.xml", "rb").read }

    it 'works' do
      expect(Sbpayment::CallbackFactory.request(nil, notice_body)).to be_instance_of Sbpayment::API::Payeasy::NoticeRequest
    end
  end

  describe 'PayEasy Cancel' do
    let(:cancel_body) { File.open("spec/fixtures/payeasy_cancel_request.xml", "rb").read }

    it 'works' do
      expect(Sbpayment::CallbackFactory.request(nil, cancel_body)).to be_instance_of Sbpayment::API::Payeasy::CancelRequest
    end
  end
end
