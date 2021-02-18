RSpec.describe Sbpayment::Link::UpdateResult do
  shared_context "prepare update result params" do
    before do
      Sbpayment.configure do |x|
        x.sandbox = true
        x.merchant_id = '19788'
        x.service_id  = '001'
        x.hashkey = '398a58952baf329cac5efbae97ea84ba17028d02'
      end

      params = query.encode('Shift_JIS').split('&').map { |e| e.split '=', 2 }.to_h
      params.each_value { |value| value.replace CGI.unescape(value) }

      @result = Sbpayment::Link::UpdateResult.new
      @result.update_attributes params, utf8: true
    end
  end

  context 'when valid params are given' do
    include_context "prepare update result params" do
      let!(:query) { 'res_payinfo_key=&free1=&cust_code=498b1fd98ebeb074ff1d50f2e2720a1a&free3=&res_sps_payment_no=&free2=&sps_hashcode=6b7981691587c72f94def4c7192e7b8c6d624b85&res_date=20150807161021&res_err_code=&limit_second=600&pay_type=2&res_payment_date=20150807161021&merchant_id=19788&request_date=20150807161004&res_pay_method=&terminal_type=0&res_sps_cust_no=&pay_method=&sps_payment_no=&res_result=OK&sps_cust_no=' }
    end

    it 'does not raise an error' do
      expect { @result.validate_sps_hashcode! }.to_not raise_error
    end
  end

  context 'when invalid params are given' do
    include_context "prepare update result params" do
      # dummpy params, modified cust_code
      let!(:query) { 'res_payinfo_key=&free1=&cust_code=998b1fd98ebeb074ff1d50f2e2720a1a&free3=&res_sps_payment_no=&free2=&sps_hashcode=6b7981691587c72f94def4c7192e7b8c6d624b85&res_date=20150807161021&res_err_code=&limit_second=600&pay_type=2&res_payment_date=20150807161021&merchant_id=19788&request_date=20150807161004&res_pay_method=&terminal_type=0&res_sps_cust_no=&pay_method=&sps_payment_no=&res_result=OK&sps_cust_no=' }
    end

    it 'raises an error' do
      expect { @result.validate_sps_hashcode! }.to raise_error Sbpayment::Link::InvalidSpsHashcodeError
    end
  end
end
