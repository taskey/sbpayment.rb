RSpec.describe 'Au API behavior' do
  describe 'SimplifiedCancelRequest' do
    before do
      # Created a purchase data with https://developer.sbpayment.jp/solution_api/sandbox/A010201
      Sbpayment.configure do |x|
        x.sandbox = true
        x.merchant_id         = '30132'
        x.service_id          = '001'
        x.basic_auth_user     = '30132001'
        x.basic_auth_password = 'c48e0e2c7d04f0954594f14c7801bd430ca6263e'
        x.hashkey             = 'c48e0e2c7d04f0954594f14c7801bd430ca6263e'
      end
    end

    around do |e|
      VCR.use_cassette 'docomo-simplified-cancel' do
        e.run
      end
    end

    it 'returns OK' do
      req                     = Sbpayment::API::Docomo::SimplifiedCancelRequest.new
      req.tracking_id         = '78977425621564'
      req.processing_datetime = '20210225010101'

      res = req.perform
      expect(res.status).to eq 200
      expect(res.headers['content-type']).to include 'text/xml'
      expect(res.body[:res_result]).to eq 'OK'
      expect(res.error).to be_nil
    end
  end
end