RSpec.describe 'proxy behavior' do

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

  describe 'proxy_uri settings' do
    before do
      Sbpayment.configure do |x|
        x.sandbox = true
        x.merchant_id = '30132'
        x.service_id  = '002'
        x.basic_auth_user     = '30132002'
        x.basic_auth_password = '8435dbd48f2249807ec216c3d5ecab714264cc4a'
        x.hashkey = '8435dbd48f2249807ec216c3d5ecab714264cc4a'
        x.proxy_uri = proxy_uri
        x.proxy_user = proxy_user
        x.proxy_password = proxy_password
      end
    end

    context 'when proxy options given' do
      let(:proxy_uri) { 'http://proxy.example.com:8000' }
      let(:proxy_user) { 'proxy_user1' }
      let(:proxy_password) { 'proxy_password1' }
      let(:proxy_options) {{
        uri:      proxy_uri,
        user:     proxy_user,
        password: proxy_password,
      }}

      it 'configure proxy' do
        stub = stub_request(:post, Sbpayment::SANDBOX_URL + Sbpayment::API_PATH).to_timeout
        expect(Faraday::ProxyOptions).to receive('from').with(proxy_options).and_call_original
        req = dummy_request
        expect { req.perform }.to raise_error(Faraday::ConnectionFailed)
        expect(stub).to have_been_requested.times(1)
      end
    end

    context 'when proxy options not given' do
      let(:proxy_uri) { nil }
      let(:proxy_user) { nil }
      let(:proxy_password) { nil }

      it 'don\'t configure proxy' do
        stub = stub_request(:post, Sbpayment::SANDBOX_URL + Sbpayment::API_PATH).to_timeout
        expect(Faraday::ProxyOptions).not_to receive('from')
        req = dummy_request
        expect { req.perform }.to raise_error(Faraday::ConnectionFailed)
        expect(stub).to have_been_requested.times(1)
      end
    end
  end
end
