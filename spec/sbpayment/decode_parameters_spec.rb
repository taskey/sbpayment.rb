RSpec.describe Sbpayment::DecodeParameters do
  class Example
    include Sbpayment::DecodeParameters
    DECRYPT_PARAMETERS = %i(foo bar)
    DECODE_PARAMETERS  = %i(foo     baz)
  end

  class ExampleWithNoConst
    include Sbpayment::DecodeParameters
  end

  before do
    Sbpayment.configure do |x|
      x.cipher_code = 'a' * 24
      x.cipher_iv   = 'b' * 8
    end
  end

  it 'returns hash w/o decode' do
    expect(ExampleWithNoConst.new.decode(foo: 'foo',
                                         bar: 'bar',
                                         baz: 'baz')).to eq(foo: 'foo',
                                                            bar: 'bar',
                                                            baz: 'baz')
  end

  it 'returns decoded hash' do
    params = {
      foo: b(e('ふー'.encode('Shift_JIS'))),
      bar: b(e('bar')),
      baz: b('baz'),
    }
    expect(Example.new.decode(params, true)).to eq(foo: 'ふー', bar: 'bar', baz: 'baz')
  end

  it 'returns decoded hash' do
    params = {
      foo: b('ふー'.encode('Shift_JIS')),
      bar: b('bar'),
      baz: b('baz'),
    }
    expect(Example.new.decode(params, false)).to eq(foo: 'ふー', bar: b('bar'), baz: 'baz')
  end

  def e(str)
    Sbpayment::Crypto.encrypt str
  end

  def b(str)
    Base64.strict_encode64 str
  end
end
