lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sbpayment/version'

Gem::Specification.new do |spec|
  spec.name          = "sbpayment"
  spec.version       = Sbpayment::VERSION
  spec.authors       = ["Kohei Hasegawa", "miyucy"]
  spec.email         = ["ameutau@gmail.com"]
  spec.homepage      = "https://github.com/quipper/sbpayment.rb"
  spec.summary       = %q{A client library for sbpayment (SB Payment Service) written in Ruby.}
  spec.description   = %q{A client library for sbpayment (SB Payment Service) written in Ruby.}
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.2'

  spec.add_dependency 'faraday', '>= 0.16.0', '< 1.4.0'
  spec.add_dependency 'builder'
  spec.add_dependency 'xml-simple'
  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'vcr', '~> 5.1.0'
  spec.add_development_dependency 'webmock', '~> 3.12.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'selenium-webdriver'
end
