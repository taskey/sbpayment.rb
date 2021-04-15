require_relative 'api_error/definitions'
require_relative 'api_error/fields'
require_relative 'api_error/feature_modules'

module Sbpayment
  # Usualy, SBPS exceptions should be a subclass of this class or a nested subclass
  class Error < StandardError; end
  class ParserError < Error; end

  # * We basically get special errors from `APIError.parse(error_code)`
  #   * When given an known `error_code`, this returns as a specific error, that is named as `API12345Error`
  #     * `123` is a payment_method code
  #     * `45` is a type code
  #     * `item` fields are not used to class name, because they do not necessarily relate to type fields
  #   * When given an unknown `error_code`, this returns an `APIUnknownError` or like a `APIUnknown101Error`
  #
  # * All SBPS API exceptions or exceptbale modules should include this module for easy to get with `begin; rescue included; end` syntax
  #   And all ancestors tree should keep the policy
  module APIError
    attr_reader :item

    # @return [String]
    def res_err_code
      str = "#{payment_method.code}#{type.code}#{@item.code}"
      PATTERN.match?(str) ? str : raise("should not reach here: #{str}")
    end
    alias_method :to_s, :res_err_code

    # @return [String]
    def summary
      "method: #{payment_method.code}(#{payment_method.summary}), type: #{type.code}(#{type.summary}), item: #{@item.code}(#{@item.summary})"
    end

    def inspect
      "#{super}: #{summary}"
    end

    PATTERN = /\A(?<payment_method>[0-9a-zA-Z]{3})(?<type>[0-9a-zA-Z]{2})(?<item>[0-9a-zA-Z]{3})\z/

    class << self
      # @param res_err_code [String]
      # @return [self]
      def parse(res_err_code)
        if /\A(?<payment_method>[0-9a-zA-Z]{3})(?<type>[0-9a-zA-Z]{2})(?<item>[0-9a-zA-Z]{3})\z/ =~ res_err_code
          class_name = :"API#{payment_method}#{type}Error"
          if Sbpayment.const_defined? class_name
            klass = Sbpayment.const_get class_name
            klass.new item: klass::Item.fetch(item)
          else
            if PAYMENT_METHOD_DEFINITIONS.include? payment_method
              Sbpayment.const_get(:"APIUnknown#{payment_method}Error").new type: Type.fetch(type), item: Item.fetch(item)
            else
              if TYPE_COMMON_DEFINITIONS.include? type
                Sbpayment.const_get(:"APIUnknownCommonType#{type}Error").new payment_method: PaymentMethod.fetch(payment_method), item: Item.fetch(item)
              else
                APIUnknownPaymentMethodError.new payment_method: PaymentMethod.fetch(payment_method), type: Type.fetch(type), item: Item.fetch(item)
              end
            end
          end
        else
          raise ParserError, "given an invalid format: #{res_err_code}"
        end
      end
    end
  end

  class APIKnownError < Error
    include APIError
    include PaymentMethodClassResponsible
    include TypeClassResponsible

    PAYMENT_METHOD = nil
    TYPE = nil

    def initialize(error_message=nil, item:)
      super error_message
      @item = item
    end
  end

  class APIUnknownError < Error
    include APIError
  end

  class APIUnknownCommonTypeError < APIUnknownError
    include TypeClassResponsible

    attr_reader :payment_method

    def initialize(error_message=nil, payment_method:, item:)
      super error_message
      @payment_method = payment_method
      @item = item
    end
  end

  class APIUnknownErrorWithPaymentMethod < APIUnknownError
    include PaymentMethodClassResponsible

    attr_reader :type

    def initialize(error_message=nil, type:, item:)
      super error_message
      @type = type
      @item = item
    end
  end

  class APIUnknownPaymentMethodError < APIUnknownError
    attr_reader :payment_method, :type

    def initialize(error_message=nil, payment_method:, type:, item:)
      super error_message
      @type = type
      @item = item
      @payment_method = payment_method
    end
  end

  APIError::TYPE_COMMON_DEFINITIONS.each_pair do |type_code, summary|
    mod = Module.new do
      include APIError
      include APIError::TypeClassResponsible
    end

    const_set :"APICommonType#{type_code}Error", mod

    root_class_for_unknowns = Class.new APIUnknownCommonTypeError do
      include mod

      self::TYPE = APIError::Type.fetch(type_code)
    end

    const_set :"APIUnknownCommonType#{type_code}Error", root_class_for_unknowns
  end

  APIError::PAYMENT_METHOD_DEFINITIONS.each_pair do |payment_method_code, summary|
    root_class_for_knowns = Class.new APIKnownError do
      self::PAYMENT_METHOD = APIError::PaymentMethod.fetch(payment_method_code)
    end

    const_set :"API#{payment_method_code}Error", root_class_for_knowns

    APIError::TYPE_COMMON_DEFINITIONS.each_key do |type_code|
      root_class = root_class_for_knowns.dup
      root_class::TYPE = APIError::Type.fetch(type_code)
      mod = const_get :"APICommonType#{type_code}Error"
      root_class.include mod

      const_set :"API#{payment_method_code}#{type_code}Error", root_class
    end

    root_class_for_unknowns = Class.new(APIUnknownErrorWithPaymentMethod) do
      self::PAYMENT_METHOD = APIError::PaymentMethod.fetch(payment_method_code)
    end

    const_set :"APIUnknown#{payment_method_code}Error", root_class_for_unknowns
  end

  APIError::TYPE_DEFINITIONS.each_pair do |payment_method_code, definitions|
    parent = const_get :"API#{payment_method_code}Error"
    parent::Type = Class.new APIError::Type do
      define_children_from definitions
    end

    definitions.each_pair do |type_code, summary|
      klass = Class.new parent do
        self::TYPE = parent::Type.fetch(type_code)
      end

      const_set :"API#{payment_method_code}#{type_code}Error", klass
    end
  end

  APIError::ITEM_DEFINITIONS.each_pair do |payment_method_code, definitions|
    pattern = /\AAPI#{payment_method_code}(?:[0-9a-zA-Z]{2})?Error\z/
    constants.grep(pattern) do |class_name|
      klass = const_get class_name
      klass::Item = Class.new APIError::Item do
        define_children_from definitions
      end
    end
  end
end
