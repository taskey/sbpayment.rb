RSpec.describe 'Credit API behavior' do
  describe 'without token' do
    before do
      Sbpayment.configure do |x|
        x.sandbox = true
        x.merchant_id = '30132'
        x.service_id = '002'
        x.basic_auth_user = '30132002'
        x.basic_auth_password = '8435dbd48f2249807ec216c3d5ecab714264cc4a'
        x.hashkey = '8435dbd48f2249807ec216c3d5ecab714264cc4a'
      end
    end

    describe 'authorization and commit' do
      describe 'mock OK request' do
        around do |e|
          VCR.use_cassette 'authorization-and-commit' do
            e.run
          end
        end

        it 'works' do
          # authorization part

          req = Sbpayment::API::Credit::AuthorizationRequest.new
          req.encrypted_flg = '0'
          req.cust_code = 'Quipper Customer ID'
          req.order_id = SecureRandom.hex
          req.item_id = 'item_1'
          req.item_name = 'item'
          req.amount = 1250

          detail = Sbpayment::API::Credit::AuthorizationRequest::Detail.new
          detail.dtl_rowno = 1
          detail.dtl_item_id = 'item_1'
          detail.dtl_item_name = 'item 1'
          detail.dtl_item_count = 2
          detail.dtl_amount = 500
          req.dtls << detail

          detail = Sbpayment::API::Credit::AuthorizationRequest::Detail.new
          detail.dtl_rowno = 2
          detail.dtl_item_id = 'item_2'
          detail.dtl_item_name = 'item 2'
          detail.dtl_item_count = 1
          detail.dtl_amount = 250
          req.dtls << detail

          req.pay_method_info.cc_number = '4242424242424242'
          req.pay_method_info.cc_expiration = '202001'
          req.pay_method_info.security_code = '000'
          req.pay_method_info.dealings_type = 10
          req.pay_option_manage.cust_manage_flg = '1'

          res = req.perform
          expect(res.status).to eq 200
          expect(res.headers['content-type']).to include 'text/xml'
          expect(res.body[:res_result]).to eq 'OK'
          expect(res.error).to be_nil

          # commit part

          req = Sbpayment::API::Credit::CommitRequest.new
          req.sps_transaction_id = res.body[:res_sps_transaction_id]
          req.tracking_id = res.body[:res_tracking_id]
          req.processing_datetime = res.body[:res_process_date]

          res = req.perform
          expect(res.status).to eq 200
          expect(res.headers['content-type']).to include 'text/xml'
          expect(res.body[:res_result]).to eq 'OK'
        end
      end

      describe 'with NG request' do
        around do |e|
          VCR.use_cassette 'authorization with invalid dealing_type' do
            e.run
          end
        end

        it 'post invalid data, respond result NG' do
          req = Sbpayment::API::Credit::AuthorizationRequest.new
          req.encrypted_flg = '0'
          req.cust_code = 'Quipper Customer ID'
          req.order_id = SecureRandom.hex
          req.item_id = 'item_1'
          req.item_name = 'item'
          req.amount = 1250

          req.pay_method_info.cc_number = '4242424242424242'
          req.pay_method_info.cc_expiration = '202001'
          req.pay_method_info.security_code = '900'
          # invalid data
          req.pay_method_info.dealings_type = 1000
          req.pay_option_manage.cust_manage_flg = '1'

          res = req.perform
          expect(res.body[:res_result]).to eq 'NG'
        end
      end

      describe 'refund' do
        around do |e|
          VCR.use_cassette 'refund' do
            e.run
          end
        end

        it 'works' do
          # authorization part
          req = Sbpayment::API::Credit::AuthorizationRequest.new
          req.encrypted_flg = '0'
          req.cust_code = 'Quipper Customer ID'
          req.order_id = SecureRandom.hex
          req.item_id = 'Item ID'
          req.amount = 1000

          req.pay_method_info.cc_number = '4242424242424242'
          req.pay_method_info.cc_expiration = '202001'
          req.pay_method_info.security_code = '000'
          req.pay_method_info.dealings_type = 10
          req.pay_option_manage.cust_manage_flg = '1'

          res = req.perform
          expect(res.status).to eq 200
          expect(res.headers['content-type']).to include 'text/xml'
          expect(res.body[:res_result]).to eq 'OK'

          authorization_sps_transaction_id = res.body[:res_sps_transaction_id]
          authorization_tracking_id = res.body[:res_tracking_id]
          authorization_processing_datetime = res.body[:res_process_date]

          # inquire part

          req = Sbpayment::API::Credit::InquireAuthorizationRequest.new
          req.encrypted_flg = '0'
          req.sps_transaction_id = authorization_sps_transaction_id
          req.tracking_id = authorization_tracking_id

          res = req.perform
          expect(res.status).to eq 200
          expect(res.headers['content-type']).to include 'text/xml'
          expect(res.body[:res_result]).to eq 'OK'
          expect(res.body[:'res_pay_method_info.res_pay_method_info_detail.cc_number']).to eq '************4242'
          expect(res.body[:'res_pay_method_info.commit_status']).to eq '0'
          expect(res.body[:'res_pay_method_info.payment_status']).to eq '1'

          # commit part

          req = Sbpayment::API::Credit::CommitRequest.new
          req.sps_transaction_id = authorization_sps_transaction_id
          req.tracking_id = authorization_tracking_id
          req.processing_datetime = authorization_processing_datetime

          res = req.perform
          expect(res.status).to eq 200
          expect(res.headers['content-type']).to include 'text/xml'
          expect(res.body[:res_result]).to eq 'OK'

          # inquire part

          req = Sbpayment::API::Credit::InquireAuthorizationRequest.new
          req.encrypted_flg = '0'
          req.sps_transaction_id = authorization_sps_transaction_id
          req.tracking_id = authorization_tracking_id

          res = req.perform
          expect(res.status).to eq 200
          expect(res.headers['content-type']).to include 'text/xml'
          expect(res.body[:res_result]).to eq 'OK'
          expect(res.body[:'res_pay_method_info.res_pay_method_info_detail.cc_number']).to eq '************4242'
          expect(res.body[:'res_pay_method_info.commit_status']).to eq '1'
          expect(res.body[:'res_pay_method_info.payment_status']).to eq '1'

          # refund part

          req = Sbpayment::API::Credit::RefundRequest.new
          req.sps_transaction_id = authorization_sps_transaction_id
          req.tracking_id = authorization_tracking_id
          req.processing_datetime = authorization_processing_datetime

          res = req.perform
          expect(res.status).to eq 200
          expect(res.headers['content-type']).to include 'text/xml'
          expect(res.body[:res_result]).to eq 'OK'

          # inquire part

          req = Sbpayment::API::Credit::InquireAuthorizationRequest.new
          req.encrypted_flg = '0'
          req.sps_transaction_id = authorization_sps_transaction_id
          req.tracking_id = authorization_tracking_id

          res = req.perform
          expect(res.status).to eq 200
          expect(res.headers['content-type']).to include 'text/xml'
          expect(res.body[:res_result]).to eq 'OK'
          expect(res.body[:'res_pay_method_info.res_pay_method_info_detail.cc_number']).to eq '************4242'
          expect(res.body[:'res_pay_method_info.commit_status']).to eq '1'
          expect(res.body[:'res_pay_method_info.payment_status']).to eq '3'
        end
      end

      describe "authorization, commit and sales" do
        around do |e|
          VCR.use_cassette 'authorization-commit-and-sales' do
            e.run
          end
        end

        it 'works' do
          # authorization part

          req = Sbpayment::API::Credit::AuthorizationRequest.new
          req.encrypted_flg = '0'
          req.cust_code = 'Quipper Customer ID'
          req.order_id = SecureRandom.hex
          req.item_id = 'item_1'
          req.item_name = 'item'
          req.amount = 1250

          detail = Sbpayment::API::Credit::AuthorizationRequest::Detail.new
          detail.dtl_rowno = 1
          detail.dtl_item_id = 'item_1'
          detail.dtl_item_name = 'item 1'
          detail.dtl_item_count = 2
          detail.dtl_amount = 500
          req.dtls << detail

          detail = Sbpayment::API::Credit::AuthorizationRequest::Detail.new
          detail.dtl_rowno = 2
          detail.dtl_item_id = 'item_2'
          detail.dtl_item_name = 'item 2'
          detail.dtl_item_count = 1
          detail.dtl_amount = 250
          req.dtls << detail

          req.pay_method_info.cc_number = '4242424242424242'
          req.pay_method_info.cc_expiration = '202001'
          req.pay_method_info.security_code = '000'
          req.pay_method_info.dealings_type = 10
          req.pay_option_manage.cust_manage_flg = '1'

          auth_res = req.perform

          expect(auth_res.status).to eq 200
          expect(auth_res.headers['content-type']).to include 'text/xml'
          expect(auth_res.body[:res_result]).to eq 'OK'
          expect(auth_res.error).to be_nil

          # commit part

          req = Sbpayment::API::Credit::CommitRequest.new
          req.sps_transaction_id = auth_res.body[:res_sps_transaction_id]
          req.tracking_id = auth_res.body[:res_tracking_id]
          req.processing_datetime = auth_res.body[:res_process_date]

          commit_res = req.perform
          expect(commit_res.status).to eq 200
          expect(commit_res.headers['content-type']).to include 'text/xml'
          expect(commit_res.body[:res_result]).to eq 'OK'

          # sales post

          req = Sbpayment::API::Credit::SalesRequest.new
          req.sps_transaction_id = auth_res.body[:res_sps_transaction_id]
          req.tracking_id = auth_res.body[:res_tracking_id]
          req.processing_datetime = auth_res.body[:res_process_date]

          sales_res = req.perform
          expect(sales_res.status).to eq 200
          expect(sales_res.headers['content-type']).to include 'text/xml'
          expect(sales_res.body[:res_result]).to eq 'OK'
        end
      end
    end

    describe 'with token' do
      before do
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
        @token, @token_key = get_tokens
      end

      around do |e|
        VCR.use_cassette 'authorization-with-token' do
          e.run
        end
      end

      describe 'authorization' do
        it 'return OK' do
          req = Sbpayment::API::Credit::AuthorizationTokenRequest.new
          req.encrypted_flg = '0'
          req.cust_code = 'Quipper Customer ID'
          req.order_id = SecureRandom.hex
          req.item_id = 'item_1'
          req.item_name = 'item'
          req.amount = 1250

          detail = Sbpayment::API::Credit::AuthorizationRequest::Detail.new
          detail.dtl_rowno = 1
          detail.dtl_item_id = 'item_1'
          detail.dtl_item_name = 'item 1'
          detail.dtl_item_count = 2
          detail.dtl_amount = 500
          req.dtls << detail

          detail = Sbpayment::API::Credit::AuthorizationRequest::Detail.new
          detail.dtl_rowno = 2
          detail.dtl_item_id = 'item_2'
          detail.dtl_item_name = 'item 2'
          detail.dtl_item_count = 1
          detail.dtl_amount = 250
          req.dtls << detail

          req.pay_option_manage.token = @token
          req.pay_option_manage.token_key = @token_key
          req.pay_method_info.dealings_type = 10
          req.pay_option_manage.cust_manage_flg = '1'

          res = req.perform
          expect(res.status).to eq 200
          expect(res.headers['content-type']).to include 'text/xml'
          expect(res.body[:res_result]).to eq 'OK'
          expect(res.body[:'res_pay_method_info.cardbrand_code']).to eq "M"
          expect(res.error).to be_nil
        end
      end
    end
  end

  describe 'Simplified' do
    describe 'cancel' do
      before do
        # Created a purchase data with https://developer.sbpayment.jp/solution_api/sandbox/A010201
        Sbpayment.configure do |x|
          x.sandbox             = true
          x.merchant_id         = '30132'
          x.service_id          = '001'
          x.basic_auth_user     = '30132001'
          x.basic_auth_password = 'c48e0e2c7d04f0954594f14c7801bd430ca6263e'
          x.hashkey             = 'c48e0e2c7d04f0954594f14c7801bd430ca6263e'
        end
      end

      around do |e|
        VCR.use_cassette 'credit-simplified-cancel' do
          e.run
        end
      end

      it 'returns OK' do
        req                     = Sbpayment::API::Credit::SimplifiedCancelRequest.new
        req.tracking_id         = '00000630883777'
        req.processing_datetime = '20210224210101'

        res = req.perform
        expect(res.status).to eq 200
        expect(res.headers['content-type']).to include 'text/xml'
        expect(res.body[:res_result]).to eq 'OK'
        expect(res.error).to be_nil
      end
    end
  end
end
