require 'sbpayment'
require 'securerandom'

Sbpayment.configure do |x|
  x.sandbox = true
  x.merchant_id = '19788'
  x.service_id  = '001'
  x.hashkey = '398a58952baf329cac5efbae97ea84ba17028d02'
end

req = Sbpayment::API::Docomo::AuthorizationRequest.new
req.cust_code        = SecureRandom.hex
req.order_id         = '必須'
req.item_id          = 'Item ID'
req.item_name        = '継続課金'
req.amount           = 980
req.pay_type         = 0
req.auto_charge_type = ""
req.service_type     = 0
req.div_settele      = ""
req.success_url      = 'http://example.com/success'
req.cancel_url       = 'http://example.com/cancel'
req.error_url        = 'http://example.com/error'
req.pagecon_url      = 'http://requestb.in/193yzl51'
req.update_sps_hashcode

# execute
res = req.perform

puts res
