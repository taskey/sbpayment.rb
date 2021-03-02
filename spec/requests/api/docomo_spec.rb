RSpec.describe 'Docomo API behavior' do
  describe 'AuthorizationRequest' do
    around do |e|
      VCR.use_cassette 'docomo-authorization' do
        e.run
      end
    end

    before do
      Sbpayment.configure do |x|
        x.sandbox = true
        x.merchant_id = '30132'
        x.service_id  = '103'
        x.basic_auth_user     = '30132103'
        x.basic_auth_password = 'ed679e1c9f90c2ab96b25d5c580b58e25192eb5d'
        x.hashkey             = 'ed679e1c9f90c2ab96b25d5c580b58e25192eb5d'
        x.cipher_code         = 'ed679e1c9f90c2ab96b25d5c'
        x.cipher_iv           = '580b58e2'
      end
      @req = Sbpayment::API::Docomo::AuthorizationRequest.new
      @req.cust_code        = SecureRandom.hex
      @req.order_id         = SecureRandom.hex
      @req.item_id          = 'item_2'
      @req.item_name        = '継続課金購入'
      @req.amount           = 980
    end

    describe '#attributes' do
      it 'keys' do
        expected_json_user_keys = %w(
          merchant_id
          service_id
          tracking_id
          cust_code
          order_id
          item_id
          item_name
          tax
          amount
          free1
          free2
          free3
          order_rowno
          request_date
          limit_second
          sps_hashcode
        )
        expect(@req.attributes.keys).to eq expected_json_user_keys
      end
    end

    describe '#update_sps_hashcode' do
      it do
        expect(@req.sps_hashcode).to eq ''
        hash_code = @req.update_sps_hashcode
        expect(@req.sps_hashcode).to eq hash_code
      end
    end

    describe '#perform' do
      context 'success' do
        # couldn't implement because trackng_id is nil
      end

      context 'failed' do
        it do
          @req.update_sps_hashcode
          res = @req.perform
          expect(res.error.class).to eq Sbpayment::API40103Error
        end
      end
    end
  end

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
