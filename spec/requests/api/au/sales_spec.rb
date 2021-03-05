RSpec.describe 'Au API behavior' do
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
  end
  describe 'SalesRequest' do
    around do |e|
      VCR.use_cassette 'au/sales_with_invalid_dealing_type' do
        e.run
      end
    end
    let(:req) do
      req = Sbpayment::API::Au::SalesRequest.new
      req.tracking_id   = SecureRandom.hex
      req.request_date  = Sbpayment::TimeUtil.format_current_time
      req
    end
    describe '#attributes' do
      it 'keys' do
        expected_json_user_keys = %w(
          merchant_id
          service_id
          tracking_id
          pay_option_manage
          request_date
          limit_second
          sps_hashcode
        )
        expect(req.attributes.keys).to eq expected_json_user_keys
      end

      describe '#perform' do
        xcontext 'success' do
          # couldn't implement because tracking_id is nil
        end
  
        context 'failed' do
          it do
            res = req.perform
            expect(res.error.class).to eq Sbpayment::API40103Error
          end
        end
      end
    end
  end
end
