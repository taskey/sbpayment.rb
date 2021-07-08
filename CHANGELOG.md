## Unreleased

### Breaking Changes
- Drop support for Ruby 2.4 and 2.5

### Interior
- Update faaday reuirement to >= 0.16.0, < 1.6.0 [#159]

## v0.15.0

### Breaking Changes
- Prefer Regexp#match? and drop ruby < 2.4 support (#132)
  - We dropped support for Ruby 2.2 and 2.3. Please use Ruby 2.4 or later.
- Raise specific error instead of ArgumentError for parsing failure (#134)
  - Please use `Sbpayment::ParserError` instead of `ArgumentError` when rescuing.
    - (Before) `Sbpayment::APIError.parse('invalid format') #=> ArgumentError`
    - (After)  `Sbpayment::APIError.parse('invalid format') #=> Sbpayment::ParserError`

### Fixed
- Fix some APIError item summary (#131)
  - Now definitions are set in `"API#{payment_method_code}#{type_code}Error"` as same as `"API#{payment_method_code}Error"`.

### Interior
- Update CI rubies (#149)
- Update vcr requirement from ~> 5.1.0 to ~> 6.0.0 (#152)

## v0.14.0

### Breaking Changes
- none

### Features
- Add support for ドコモ、au 売上要求処理 (継続課金(定期・従量)) (#125 / @tashirosota) 

### Fixed
- none

### Deprecated
- Change Softbank::CommitRequest to Softbank::SalesRequest (#141 / @tashirosota)
  - `Sbpayment::API::Softbank::CommitRequest` was renamed for `Sbpayment::API::Softbank::SalesRequest`.
  - We'll remove or redefine `Sbpayment::API::Softbank::CommitRequest` in future versions.

### Interior
- Update webmock requirement from ~> 3.11.2 to ~> 3.12.0 (#145)

## v0.13.0

### Breaking Changes
- none

### Features
- Implement Sbpayment::API::Au::SimplifiedCancelRequest (#144)
- Implement Sbpayment::API::Docomo::SimplifiedCancelRequest (#143)
- Implement Sbpayment::API::Credit::SimplifiedCancelRequest (#142)

### Fixed
- none

### Interior
- Remove unused code from spec (#136)
- Care bundler deprecation in CI (#138)
- Add Docker development section in README (#139)
- Enable `Zero monkey patching mode` in rspec (#140)
- Update CI rubies and test in latest too (#137)

## v0.12.0

- Add support for ST01-00104-401 ドコモケータイ払い 購入要求要求処理 (継続課金(定期・従量)) (#93 / @tashirosota)
- Add support for ST01-00104-402 auかんたん決済 購入要求要求処理 (継続課金(定期・従量)) (#94 / @tashirosota)
- Loosen version requirement of faraday to allow < 1.2.0.  It was formerly < 1.1.0. (#117)

## v0.11.1
- Fix proxy configuration error with faraday 1.0+ (#112)

## v0.11.0
- Change chromedriver-helper to webdrivers (#92)
- Update vcr version requirement ('~> 5.1.0') (#106)
- Update webmock version requirement ('~> 3.8.3') (#108)
- Update faraday version requirement ('>= 0.16.0', '< 1.1.0') (#103)
- Update bundler version requirement ('~> 2.1') (#102)

## v0.10.2

- Update faraday version requirement
