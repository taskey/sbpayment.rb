# sbpayment.rb [![Circle CI](https://img.shields.io/circleci/project/quipper/sbpayment.rb.svg)](https://circleci.com/gh/quipper/sbpayment.rb) [![Rubygems](https://img.shields.io/gem/v/sbpayment.svg)](https://rubygems.org/gems/sbpayment)

A client library for [sbpayment (SB Payment Service)](http://www.sbpayment.jp) written in Ruby.

This library is not an official library, please use at your own risk.

## Installation

```ruby
gem 'sbpayment'
```

## Usage

### Example

See [example](example).

### Configure Options

```rb
Sbpayment.configure do |x|
  x.sandbox = true
  ...
end
```

Properties                | Description                                                                                                                       | Default | Required | Type    |
---                       | ---                                                                                                                               | ---     | ---      | ---     |
sandbox                   | when this option is true, endpoint will be SBPS Developer Console's one                                                           | false   | false    | Boolean |
basic_auth_user           | use basic auth user given by sbpayment                                                                                            | ""      | false    | String  |
basic_auth_password       | user basic auth password given by sbpayment                                                                                       | ""      | false    | String  |
merchant_id               | merchant_id for a params to request                                                                                               | ""      | true     | String  |
service_id                | service_id for a params to request                                                                                                | ""      | true     | String  |
cipher_code               | use cipher_code given by sbpayment                                                                                                | ""      | false    | String  |
cipher_iv                 | use cipher_iv given by sbpayment                                                                                                  | ""      | false    | String  |
hashkey                   | use hashkey given by sbpayment                                                                                                    | ""      | true     | String  |
proxy_uri                 | set forward proxy uri if you need                                                                                                 | ""      | false    | String  |
proxy_user                | set forward proxy's user if you need                                                                                              | ""      | false    | String  |
proxy_password            | set forward proxy's password if you need                                                                                          | ""      | false    | String  |
retry_max_counts          | set max retry counts if you need                                                                                                  | 3       | false    | Integer |
open_timeout              | set number of seconds to wait for the connection to open                                                                          | nil     | false    | Integer |
timeout                   | set number of seconds to wait for reading                                                                                         | nil     | false    | Integer |


### Supported Actions

Implemented actions are only for what we needed so far. Feel free to add here if you need it.

### Caveat

Currently client side encoding is supported only for UTF-8. (UTF-8 to Shift-JIS)

#### API

##### Credit

Action Name                   | sps-api-request id | Request class                                         |
---                           | ---                | ---                                                   |
与信要求                      | `ST01-00111-101`   | `Sbpayment::API::Credit::AuthorizationRequest`        |
与信要求(トークン)            | `ST01-00131-101`   | `Sbpayment::API::Credit::AuthorizationTokenRequest`   |
再与信要求                    | `ST01-00113-101`   | `Sbpayment::API::Credit::ReAuthorizationRequest`      |
コミット (確定処理)           | `ST02-00101-101`   | `Sbpayment::API::Credit::CommitRequest`               |
売り上げ連携                  | `ST02-00201-101`   | `Sbpayment::API::Credit::SalesRequest`                |
決済結果参照                  | `MG01-00101-101`   | `Sbpayment::API::Credit::InquireAuthorizationRequest` |
取消要求                      | `ST02-00305-101`   | `Sbpayment::API::Credit::CancelAuthorizationRequest`  |
返金要求                      | `ST02-00303-101`   | `Sbpayment::API::Credit::RefundRequest`               |
部分返金要求                  | `ST02-00307-101`   | `Sbpayment::API::Credit::PartlyRefundRequest`         |
顧客情報登録                  | `MG02-00101-101`   | `Sbpayment::API::Credit::CreateCustomerRequest`       |
顧客情報更新                  | `MG02-00102-101`   | `Sbpayment::API::Credit::UpdateCustomerRequest`       |
顧客情報登録(トークン)        | `MG02-00131-101`   | `Sbpayment::API::Credit::CreateCustomerTokenRequest`  |
顧客情報更新(トークン)        | `MG02-00132-101`   | `Sbpayment::API::Credit::UpdateCustomerTokenRequest`  |
顧客情報削除                  | `MG02-00103-101`   | `Sbpayment::API::Credit::DeleteCustomerRequest`       |
顧客情報参照                  | `MG02-00104-101`   | `Sbpayment::API::Credit::ReadCustomerRequest`         |

##### Carrier

###### Docomo

Action Name                                      | sps-api-request id | Request class                                           |
---                                              | ---                | ---                                                     |
ドコモケータイ払い 取消・返金要求処理 (簡易継続) | `ST02-00303-401`   | `Sbpayment::API::Docomo::SimplifiedCancelRefundRequest` |
ドコモケータイ払い 購入要求要求処理 (継続課金(定期・従量)) | `ST01-00104-401`   | `Sbpayment::API::Docomo::AuthorizationRequest` |

###### au

Action Name                       | sps-api-request id | Request class                       |
---                               | ---                | ---                                 |
auかんたん決済 取消・返金要求処理 | `ST02-00303-402`   | `Sbpayment::API::Au::CancelRefundRequest` |
auかんたん決済 購入要求要求処理 (継続課金(定期・従量)) | `ST01-00104-402`   | `Sbpayment::API::Au::AuthorizationRequest` |

###### Softbank

Action Name                                              | sps-api-request id | Request class                                    |
---                                                      | ---                | ---                                              |
ソフトバンクまとめて支払い B 継続課金(定期) 要求処理     | `ST01-00104-405`   | `Sbpayment::API::Softbank::AuthorizationRequest` |
ソフトバンクまとめて支払い B 継続課金(定期) 確定処理     | `ST02-00201-405`   | `Sbpayment::API::Softbank::CommitRequest`        |
ソフトバンクまとめて支払い(B)継続課金(定期) 取消返金要求 | `ST02-00303-405`   | `Sbpayment::API::Softbank::CancelRefundRequest`  |

##### Webcvs

Action Name               | sps-api-request id | Request class                                      |
---                       | ---                | ---                                                |
WEBコンビニ決済要求       | `ST01-00101-701`   | `Sbpayment::API::Webcvs::PaymentRequest`           |
WEBコンビニ決済結果参照   | `ST01-00101-701`   | `Sbpayment::API::Webcvs::ReadPaymentResultRequest` |
WEBコンビニ入金通知       | `NT01-00103-701`   | `Sbpayment::API::Webcvs::NoticeRequest`            |
WEBコンビニキャンセル通知 | `NT01-00104-701`   | `Sbpayment::API::Webcvs::CancelRequest`            |

##### Payeasy

Action Name            | sps-api-request id | Request class                             |
---                    | ---                | ---                                       |
PayEasy 決済要求       | `ST01-00101-703`   | `Sbpayment::API::Payeasy::PaymentRequest` |
PayEasy 入金通知       | `NT01-00103-703`   | `Sbpayment::API::Payeasy::NoticeRequest`  |
PayEasy キャンセル通知 | `NT01-00104-703`   | `Sbpayment::API::Payeasy::CancelRequest`  |

## Tips

### Check error codes for debugging

```
./bin/console
2.3.3 (main):0 > Sbpayment::APIError.parse("99990999")
=> #<Sbpayment::API99990Error: 99990999>: method: 999(共通), type: 90(API システムエラー), item: 999(該当項目なし)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/quipper/sbpayment.rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
