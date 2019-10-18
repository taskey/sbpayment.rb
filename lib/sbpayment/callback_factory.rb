require 'xmlsimple'

module Sbpayment
  module CallbackFactory
    module_function

    def request(headers, body)
      klass = detect_request(body)
      klass.new headers, body
    end

    def detect_request(body)
      request_class[XmlSimple.xml_in(body)['id']]
    end

    def request_class
      {
        'NT01-00103-701' => Sbpayment::API::Webcvs::NoticeRequest,
        'NT01-00104-701' => Sbpayment::API::Webcvs::CancelRequest,
        'NT01-00103-703' => Sbpayment::API::Payeasy::NoticeRequest,
        'NT01-00104-703' => Sbpayment::API::Payeasy::CancelRequest
      }
    end
  end
end
