RSpec.describe 'timeout behavior' do

  def dummy_request
    req = Sbpayment::API::Credit::AuthorizationRequest.new
    req.encrypted_flg = '0'
    req.cust_code = 'Quipper Customer ID'
    req.order_id  = SecureRandom.hex
    req.item_id   = 'Item ID'
    req.amount    = 1000

    req.pay_method_info.cc_number     = '4242424242424242'
    req.pay_method_info.cc_expiration = '202001'
    req.pay_method_info.security_code = '000'
    req.pay_method_info.dealings_type = 10
    req.pay_option_manage.cust_manage_flg = '1'
    req
  end

  describe 'open_timeout and timeout settings' do
    let(:faraday_options) {{
      url: Sbpayment::SANDBOX_URL,
      request: {
        open_timeout: open_timeout,
        timeout: timeout
      }
    }}

    before do
      Sbpayment.configure do |x|
        x.sandbox = true
        x.merchant_id = '30132'
        x.service_id  = '002'
        x.basic_auth_user     = '30132002'
        x.basic_auth_password = '8435dbd48f2249807ec216c3d5ecab714264cc4a'
        x.hashkey = '8435dbd48f2249807ec216c3d5ecab714264cc4a'
        x.open_timeout = open_timeout
        x.timeout = timeout
      end
    end

    shared_examples 'to initialize Faraday with options' do
      it 'passes timeout options' do
        stub = stub_request(:post, Sbpayment::SANDBOX_URL + Sbpayment::API_PATH).to_timeout
        expect(Faraday).to receive('new').with(faraday_options).and_call_original
        req = dummy_request
        expect { req.perform }.to raise_error(Faraday::ConnectionFailed)
        expect(stub).to have_been_requested.times(1)
      end
    end

    context 'when timeout options as a number' do
      let(:open_timeout) { 3 }
      let(:timeout)      { 9 }

      it_behaves_like 'to initialize Faraday with options'
    end

    context 'when timeout options as nil' do
      let(:open_timeout) { nil }
      let(:timeout)      { nil }

      it_behaves_like 'to initialize Faraday with options'
    end
  end
end
