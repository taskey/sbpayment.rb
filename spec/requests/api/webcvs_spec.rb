RSpec.describe 'Webcvs API behavior' do
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

  describe 'read payment result' do
    around do |e|
      VCR.use_cassette 'webcvs-read-payment-result' do
        e.run
      end
    end

    it 'works' do
      # payment part
      req = Sbpayment::API::Webcvs::PaymentRequest.new

      req.cust_code = 'Quipper Customer ID'
      req.order_id  = SecureRandom.hex
      req.item_id   = 'item_1'
      req.item_name = 'item'
      req.amount    = 1250
      req.order_rowno = 1

      detail = Sbpayment::API::Webcvs::PaymentRequest::Detail.new
      detail.dtl_rowno      = 1
      detail.dtl_item_id    = 'item_1'
      detail.dtl_item_name  = 'item 1'
      detail.dtl_item_count = 2
      detail.dtl_amount     = 500
      req.dtls << detail

      detail = Sbpayment::API::Webcvs::PaymentRequest::Detail.new
      detail.dtl_rowno      = 2
      detail.dtl_item_id    = 'item_2'
      detail.dtl_item_name  = 'item 2'
      detail.dtl_item_count = 1
      detail.dtl_amount     = 250
      req.dtls << detail

      req.pay_method_info.issue_type = '0'
      req.pay_method_info.last_name = 'てすと'
      req.pay_method_info.first_name = '　'     # full-width whitespace
      req.pay_method_info.last_name_kana = 'テスト'
      req.pay_method_info.first_name_kana = nil
      req.pay_method_info.first_zip = '000'
      req.pay_method_info.second_zip = '0000'
      req.pay_method_info.add1 = '　'           # full-width whitespace
      req.pay_method_info.add2 = '　'           # full-width whitespace
      req.pay_method_info.add3 = nil
      req.pay_method_info.tel = '0312345678'
      req.pay_method_info.mail = 'cvs@dummy.com'
      req.pay_method_info.seiyakudate = Time.now.strftime('%Y%m%d')
      req.pay_method_info.webcvstype = '002'
      req.pay_method_info.bill_date = Time.now.strftime('%Y%m%d')
      req.encrypted_flg = '0'

      res = req.perform

      expect(res.status).to eq 200
      expect(res.headers['content-type']).to include 'text/xml'
      expect(res.body[:res_result]).to eq 'OK'

      # read payment result part
      req = Sbpayment::API::Webcvs::ReadPaymentResultRequest.new
      req.encrypted_flg = '0'
      req.sps_transaction_id = res.body[:res_sps_transaction_id]
      req.tracking_id = res.body[:res_tracking_id]

      res = req.perform

      expect(res.status).to eq 200
      expect(res.headers['content-type']).to include 'text/xml'
      expect(res.body[:res_result]).to eq 'OK'
      expect(res.body[:res_sps_transaction_id]).to eq 'B71210007MG010010170100188245657'
      expect(res.body[:res_status]).to eq '0'
      expect(res.body[:'res_pay_method_info.webcvstype']).to eq '002'
      expect(res.body[:'res_pay_method_info.invoice_no']).to eq '83897187434765'
      expect(res.body[:'res_pay_method_info.bill_date']).to eq '20161028'
      expect(res.body[:'res_pay_method_info.cvs_pay_data1']).to eq '30654892-426543614'
      expect(res.body[:'res_pay_method_info.cvs_pay_data2']).to eq 'https://cvsshiharai.densan-s.co.jp/Haraikomi.aspx?order1=30654892&order2=426543614'
      expect(res.body[:'res_pay_method_info.payment_status']).to eq '1'
      expect(res.body[:res_process_date]).to eq '20161028192250'
      expect(res.body[:res_date]).to eq '20161028192251'
    end
  end

  describe "notice" do
    let(:request_body) { File.open("spec/fixtures/webcvs_notice_request.xml", "rb").read }
    let(:request_header) { nil }
    let(:response_body) { File.open("spec/fixtures/webcvs_notice_response.xml", "rb").read.strip }

    it "works" do
      request = Sbpayment::CallbackFactory.request(request_header, request_body)
      expect(request).to be_kind_of Sbpayment::API::Webcvs::NoticeRequest
      expect(request.body[:merchant_id]).to eq '99999'
      expect(request.body[:service_id]).to eq '999'
      expect(request.body[:sps_transaction_id]).to eq 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      expect(request.body[:tracking_id]).to eq '12345678901234'
      expect(request.body[:rec_datetime]).to eq '20091010'
      expect(request.body[:'pay_method_info.rec_type']).to eq '1'
      expect(request.body[:'pay_method_info.rec_amount']).to eq '10800'
      expect(request.body[:'pay_method_info.rec_amount_total']).to eq '10800'
      expect(request.body[:'pay_method_info.res_mail']).to eq 'payeasy@ps.softbank.co.jp'
      expect(request.body[:'pay_method_info.rec_extra']).to eq '備考'
      expect(request.body[:request_date]).to eq '20091010125959'
      expect(request.body[:sps_hashcode]).to eq request.generate_sps_hashcode

      response = request.response_class.new
      response.res_result = 'OK'
      expect(response.to_xml).to eq response_body
    end

    let(:response_body_with_error) { File.open("spec/fixtures/webcvs_notice_response_with_error.xml", "rb").read.strip }
    it "encodes to sjis" do
      response_err = Sbpayment::API::Webcvs::NoticeResponse.new
      response_err.res_result = 'NG'
      response_err.res_err_msg = 'エラーメッセージ'
      expect(response_err.to_xml).to eq response_body_with_error
    end
  end

  describe "cancel" do
    let(:request_body) { File.open("spec/fixtures/webcvs_cancel_request.xml", "rb").read }
    let(:request_header) { nil }
    let(:response_body) { File.open("spec/fixtures/webcvs_cancel_response.xml", "rb").read.strip }

    it "works" do
      request = Sbpayment::CallbackFactory.request(request_header, request_body)
      expect(request).to be_kind_of Sbpayment::API::Webcvs::CancelRequest
      expect(request.body[:service_id]).to eq '999'
      expect(request.body[:sps_transaction_id]).to eq 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      expect(request.body[:tracking_id]).to eq '12345678901234'
      expect(request.body[:rec_datetime]).to eq '20091010'
      expect(request.body[:request_date]).to eq '20091010125959'
      expect(request.body[:sps_hashcode]).to eq request.generate_sps_hashcode

      response = request.response_class.new
      response.res_result = 'OK'
      expect(response.to_xml).to eq response_body
    end

    let(:response_body_with_error) { File.open("spec/fixtures/webcvs_cancel_response_with_error.xml", "rb").read.strip }
    it "encodes to sjis" do
      response_err = Sbpayment::API::Webcvs::CancelResponse.new
      response_err.res_result = 'NG'
      response_err.res_err_msg = 'エラーメッセージ'
      expect(response_err.to_xml).to eq response_body_with_error
    end
  end
end
