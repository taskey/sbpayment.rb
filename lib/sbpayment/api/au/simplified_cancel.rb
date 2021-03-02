require_relative '../../request'
require_relative '../../response'

module Sbpayment
  module API
    module Au
      class SimplifiedCancelRequest < Request
        tag 'sps-api-request', id: 'ST02-00302-402'
        key :merchant_id, default: -> { Sbpayment.config.merchant_id }
        key :service_id,  default: -> { Sbpayment.config.service_id }
        key :tracking_id
        key :processing_datetime
        key :request_date, default: -> { TimeUtil.format_current_time }
        key :limit_second
        key :sps_hashcode
      end

      class SimplifiedCancelResponse < Response
      end
    end
  end
end
