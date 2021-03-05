require_relative '../../request'
require_relative '../../response'

module Sbpayment
  module API
    module Softbank
      class CommitRequest < Request
        class PayOptionManage
          include ParameterDefinition

          tag 'pay_option_manage'
          key :amount
        end

        def initialize(*arg, &blk)
          warn 'Sbpayment::API::Softbank::CommitRequest is deprecated, should use Sbpayment::API::Softbank::SalesRequest'
          super(*arg, &blk)
        end
 
        tag 'sps-api-request', id: 'ST02-00201-405'
        key :merchant_id, default: -> { Sbpayment.config.merchant_id }
        key :service_id,  default: -> { Sbpayment.config.service_id }
        key :tracking_id
        key :pay_option_manage, class: PayOptionManage
        key :request_date, default: -> { TimeUtil.format_current_time }
        key :limit_second
        key :sps_hashcode
      end

      class CommitResponse < Response
      end
    end
  end
end
