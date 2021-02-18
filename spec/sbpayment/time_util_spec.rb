RSpec.describe Sbpayment::TimeUtil do
  around do |example|
    ENV['TZ'], old = 'UTC', ENV['TZ']
    example.run
    ENV['TZ'] = old
  end

  describe '.format_current_time' do
    subject             { described_class.format_current_time }
    let!(:running_time) { Time.local 2016, 5, 2 }

    around do |example|
      Timecop.freeze running_time do
        example.run
      end
    end

    it do
      jst = running_time + 9 * 60 * 60
      is_expected.to eq(jst.strftime Sbpayment::TimeUtil::STRFTIME_FORMAT)
    end
  end

  describe '.in_jst' do
    it do
      expect(Time.now.zone).to eq('UTC')
      described_class.in_jst { expect(Time.now.zone).to eq('JST') }
      expect(Time.now.zone).to eq('UTC')
    end
  end
end
