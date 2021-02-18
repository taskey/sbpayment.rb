require 'rexml/document'

RSpec.describe Sbpayment::ParameterDefinition do
  class Example
    include Sbpayment::ParameterDefinition

    class Item
      include Sbpayment::ParameterDefinition

      tag 'item'
      key :name, tag: 'itemName'
    end
    class Option
      include Sbpayment::ParameterDefinition

      tag 'opt'
      key :color
    end

    tag 'Examples', attr: 'value'
    key :foo, type: :M
    key :bar, encrypt: true
    key :baz, default: 'default value'
    key :qux, default: -> { 'default value' }
    many :items
    key :option, class: Option
    key :sps_hashcode
  end

  before do
    Sbpayment.configure do |x|
      x.cipher_code = SecureRandom.hex(12)
      x.cipher_iv   = SecureRandom.hex(4)
      x.hashkey     = SecureRandom.hex
    end

    @obj = Example.new
    @obj.foo = 'ふー'
    @obj.bar = 'bar'
    @obj.items.push Example::Item.new.tap { |i| i.name = 'item a' }
    @obj.items.push Example::Item.new.tap { |i| i.name = 'item b' }
    @obj.option.color = 'red'
    @doc = REXML::Document.new @obj.to_sbps_xml(need_encrypt: true)
  end

  it 'has xml_tag and xml_attributes' do
    expect(Example.xml_tag).to eq 'Examples'
    expect(Example.xml_attributes).to eq(attr: 'value')
  end

  describe 'to_sbps_xml' do
    it 'type option' do
      val = REXML::XPath.first(@doc, '/Examples/foo').text
      expect(Sbpayment::Encoding.sjis2utf8 Base64.strict_decode64(val)).to eq 'ふー'
    end

    it 'encrypt option' do
      val = REXML::XPath.first(@doc, '/Examples/bar').text
      expect(Sbpayment::Crypto.decrypt(Base64.strict_decode64(val))).to eq 'bar'
    end

    it 'many' do
      expect(REXML::XPath.match(@doc, '/Examples/items/item').size).to eq 2
    end

    it 'tag option' do
      expect(REXML::XPath.match(@doc, '/Examples/items/item/itemName').map(&:text)).to eq ['item a', 'item b']
    end

    it 'class option' do
      expect(REXML::XPath.first(@doc, '/Examples/opt/color').text).to eq 'red'
    end

    context 'default option' do
      it 'has default option when default option is not proc' do
        expect(REXML::XPath.first(@doc, '/Examples/baz').text).to eq 'default value'
      end

      it 'has default option when default option is proc' do
        expect(REXML::XPath.first(@doc, '/Examples/qux').text).to eq 'default value'
      end
    end
  end

  describe 'update_sps_hashcode' do
    before do
      @obj.update_sps_hashcode
    end

    it 'update sps_hashcode' do
      expect(@obj.sps_hashcode).to eq Digest::SHA1.hexdigest('ふー'.encode('Shift_JIS') + 'bar' + 'default value' + 'default value' + 'item a' + 'item b' + 'red' + Sbpayment.config.hashkey).encode 'Shift_JIS'
    end
  end

  describe 'update_attributes' do
    context 'when sbpayment returns as sjis and update as sjis' do
      before do
        @obj.update_attributes({foo: 'ふー'.encode('Shift_JIS')});
      end

      it 'updates attributes as sjis' do
        expect(@obj.attributes['foo']).to eq 'ふー'.encode('Shift_JIS')
      end
    end

    context 'when sbpayment returns as sjis and update as utf8' do
      before do
        @obj.update_attributes({foo: 'ふー'.encode('Shift_JIS')}, utf8: true);
      end

      it 'updates attributes as utf8' do
        expect(@obj.attributes['foo']).to eq 'ふー'
      end
    end
  end
end
