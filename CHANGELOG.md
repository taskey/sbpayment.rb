## Unreleased
- none

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
