require_relative '../../request'
require_relative '../../response'

module Sbpayment
  module API
    module Au
      class AuthorizationRequest < Request
        tag 'sps-api-request', id: 'ST01-00104-402'
        key :merchant_id, default: -> { Sbpayment.config.merchant_id }
        key :service_id,  default: -> { Sbpayment.config.service_id }
        key :tracking_id
        key :cust_code
        key :order_id
        key :item_id
        key :item_name, type: :M
        key :tax
        key :amount
        key :free1, type: :M
        key :free2, type: :M
        key :free3, type: :M
        key :order_rowno
        key :request_date, default: -> { TimeUtil.format_current_time }
        key :limit_second
        key :sps_hashcode
      end

      class AuthorizationResponse < Response
      end
    end
  end
end
