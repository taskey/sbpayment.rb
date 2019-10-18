require 'faraday'
require_relative 'parameter_definition'

module Sbpayment
  class Request
    RETRY_INTERVAL  = 1
    DEFAULT_HEADERS = { 'content-type' => 'text/xml' }

    include ParameterDefinition

    def response_class
      self.class.const_get self.class.name.sub(/Request\z/, 'Response')
    end

    def perform
      config = Sbpayment.config

      url = config.sandbox ? Sbpayment::SANDBOX_URL : Sbpayment::PRODUCTION_URL

      faraday_options = {
        url: url,
        request: {
          open_timeout: config.open_timeout,
          timeout: config.timeout
        }
      }
      connection = Faraday.new(faraday_options) do |builder|
        builder.request :retry, max: config.retry_max_counts, interval: RETRY_INTERVAL, exceptions: [Errno::ETIMEDOUT, Timeout::Error, Faraday::Error::TimeoutError, Faraday::Error::ConnectionFailed]
        builder.request :basic_auth, config.basic_auth_user, config.basic_auth_password
        builder.adapter Faraday.default_adapter

        if config.proxy_uri
          options = { uri: config.proxy_uri, user: config.proxy_user, password: config.proxy_password }
          builder.proxy options
        end
      end

      update_sps_hashcode
      response = connection.post Sbpayment::API_PATH, to_sbps_xml(need_encrypt: need_encrypt?), DEFAULT_HEADERS
      response_class.new response.status, response.headers, response.body, need_decrypt: need_encrypt?
    end

    alias execute perform

    private

    def need_encrypt?
      keys.key?('encrypted_flg') && read_params('encrypted_flg').to_s == '1'
    end
  end
end
