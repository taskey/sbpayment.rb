require 'xmlsimple'
require_relative 'shallow_hash'
require_relative 'decode_parameters'

module Sbpayment
  class Response
    using ShallowHash

    include DecodeParameters

    attr_reader :status, :headers, :body

    def initialize(status, headers, body, need_decrypt: false)
      @status  = status
      @headers = headers
      @body    = XmlSimple.xml_in(body, forcearray: false, noattr: true, keytosymbol: true, suppressempty: true).shallow
      @body    = decode @body, need_decrypt
    end

    def error
      code = body[:res_err_code]
      code && APIError.parse(code)
    end

    def success?
      body[:res_result] == 'OK'
    end
  end
end
