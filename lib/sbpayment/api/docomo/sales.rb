require_relative '../../request'
require_relative '../../response'

module Sbpayment
  module API
    module Docomo
      class PayOptionManage
        include ParameterDefinition

        tag 'pay_option_manage'
        key :amount
      end

      class SalesRequest < Request
        tag 'sps-api-request', id: 'ST02-00201-401'
        key :merchant_id, default: -> { Sbpayment.config.merchant_id }
        key :service_id,  default: -> { Sbpayment.config.service_id }
        key :tracking_id
        key :pay_option_manage, class: PayOptionManage
        key :request_date, default: -> { TimeUtil.format_current_time }
        key :limit_second
        key :sps_hashcode
      end

      class SalesResponse < Response
      end
    end
  end
end

