RSpec.describe Sbpayment::ShallowHash do
  using Sbpayment::ShallowHash

  describe 'Hash#shallow' do
    it 'returns new hash' do
      h = {
        a: {
          b: {
            c: 'd.e.f'
          }
        },
        'd' => {
          'e' => {
            'f' => 'g.h.i'
          }
        }
      }

      expect(h.shallow).to eq(:'a.b.c' => 'd.e.f', :'d.e.f' => 'g.h.i')
    end
  end
end
