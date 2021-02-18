RSpec.describe 'Customer API behavior' do
  let(:cust_code) { SecureRandom.hex }

  describe 'withou token' do
    around do |e|
      VCR.use_cassette 'customer-api' do
        e.run
      end
    end

    before do
      Sbpayment.configure do |x|
        x.sandbox = true
        x.merchant_id = '30132'
        x.service_id  = '002'
        x.basic_auth_user     = '30132002'
        x.basic_auth_password = '8435dbd48f2249807ec216c3d5ecab714264cc4a'
        x.hashkey = '8435dbd48f2249807ec216c3d5ecab714264cc4a'
      end
    end

    it 'CRUD' do
      req = Sbpayment::API::Credit::CreateCustomerRequest.new
      req.cust_code = cust_code
      req.encrypted_flg = '0'
      req.pay_method_info.cc_number = '4242424242424242'
      req.pay_method_info.cc_expiration = '202001'
      req.pay_method_info.security_code = '000'
      req.pay_method_info.resrv1 = 'テストユーザー'
      res = req.perform
      expect(res.status).to eq 200
      expect(res.headers['content-type']).to include 'text/xml'
      expect(res.body[:res_result]).to eq 'OK'
      expect(res.body[:'res_pay_method_info.cardbrand_code']).to eq 'V'

      req = Sbpayment::API::Credit::ReadCustomerRequest.new
      req.cust_code = cust_code
      req.encrypted_flg = '0'
      res = req.perform
      expect(res.status).to eq 200
      expect(res.headers['content-type']).to include 'text/xml'
      expect(res.body[:res_result]).to eq 'OK'
      expect(res.body[:'res_pay_method_info.cc_number']).to eq '************4242'
      expect(res.body[:'res_pay_method_info.cc_expiration']).to eq '202001'
      expect(res.body[:'res_pay_method_info.cardbrand_code']).to eq 'V'
      expect(res.body[:'res_pay_method_info.resrv1']).to eq 'テストユーザー'

      req = Sbpayment::API::Credit::UpdateCustomerRequest.new
      req.cust_code = cust_code
      req.encrypted_flg = '0'
      req.pay_method_info.cc_number = '4012888888881881'
      req.pay_method_info.cc_expiration = '202212'
      req.pay_method_info.security_code = '000'
      req.pay_method_info.resrv1 = 'テストユーザー1'
      res = req.perform
      expect(res.status).to eq 200
      expect(res.headers['content-type']).to include 'text/xml'
      expect(res.body[:res_result]).to eq 'OK'
      expect(res.body[:'res_pay_method_info.cardbrand_code']).to eq 'V'

      req = Sbpayment::API::Credit::ReadCustomerRequest.new
      req.cust_code = cust_code
      req.encrypted_flg = '0'
      res = req.perform
      expect(res.status).to eq 200
      expect(res.headers['content-type']).to include 'text/xml'
      expect(res.body[:res_result]).to eq 'OK'
      expect(res.body[:'res_pay_method_info.cc_number']).to eq '************1881'
      expect(res.body[:'res_pay_method_info.cc_expiration']).to eq '202212'
      expect(res.body[:'res_pay_method_info.cardbrand_code']).to eq 'V'
      expect(res.body[:'res_pay_method_info.resrv1']).to eq 'テストユーザー1'

      req = Sbpayment::API::Credit::DeleteCustomerRequest.new
      req.cust_code = cust_code
      req.encrypted_flg = '0'
      res = req.perform
      expect(res.status).to eq 200
      expect(res.headers['content-type']).to include 'text/xml'
      expect(res.body[:res_result]).to eq 'OK'
    end
  end

  describe 'with token' do
    before :each do
      Sbpayment.configure do |x|
        x.sandbox = true
        x.merchant_id = '30132'
        x.service_id = '002'
        x.basic_auth_user = '30132002'
        x.basic_auth_password = '8435dbd48f2249807ec216c3d5ecab714264cc4a'
        x.hashkey = '8435dbd48f2249807ec216c3d5ecab714264cc4a'
        x.cipher_code = 'c'*24
        x.cipher_iv = 'aaaaaaaa'
      end
    end

    before :all do
      @cust_code_for_request_with_token = SecureRandom.hex
    end

    describe 'create with token' do
      before do
        @token, @token_key = get_tokens
      end

      around do |e|
        VCR.use_cassette 'customer-api-create-with-token' do
          e.run
        end
      end

      it 'returns OK' do
        req = Sbpayment::API::Credit::CreateCustomerTokenRequest.new
        req.cust_code = @cust_code_for_request_with_token
        req.encrypted_flg = '0'
        req.pay_option_manage.token = @token
        req.pay_option_manage.token_key = @token_key
        req.pay_method_info.resrv1 = 'テストユーザー'
        res = req.perform
        expect(res.status).to eq 200
        expect(res.headers['content-type']).to include 'text/xml'
        expect(res.body[:res_result]).to eq 'OK'
        expect(res.body[:'res_pay_method_info.cardbrand_code']).to eq "M"
      end
    end

    describe 'update with token' do
      before do
        @token, @token_key = get_tokens
      end

      around do |e|
        VCR.use_cassette 'customer-api-update-with-token' do
          e.run
        end
      end

      it 'returns OK' do
        req = Sbpayment::API::Credit::UpdateCustomerTokenRequest.new
        req.cust_code = @cust_code_for_request_with_token
        req.encrypted_flg = '0'
        req.pay_option_manage.token = @token
        req.pay_option_manage.token_key = @token_key
        req.pay_method_info.resrv1 = 'テストユーザー1'
        res = req.perform
        expect(res.status).to eq 200
        expect(res.headers['content-type']).to include 'text/xml'
        expect(res.body[:res_result]).to eq 'OK'
        expect(res.body[:'res_pay_method_info.cardbrand_code']).to eq "M"
      end
    end
  end
end
