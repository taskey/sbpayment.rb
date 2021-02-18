$LOAD_PATH.unshift(__dir__)
$LOAD_PATH.unshift(File.join(__dir__, '..', 'lib'))

require 'securerandom'
require 'sbpayment'
require 'rspec'
require 'webmock/rspec'
require 'vcr'
require 'pry'
require 'timecop'
require 'selenium-webdriver'

require_relative 'support/get_tokens_helper'

RSpec.configure do |c|
  c.disable_monkey_patching!
  c.warnings = true
  c.raise_on_warning = true
  c.include GetTokensHelper
end

VCR.configure do |config|
  config.ignore_hosts 'jsbin.com' # Ignore jsbin.com to generate token
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.default_cassette_options = {
    serialize_with: :syck
  }
end
