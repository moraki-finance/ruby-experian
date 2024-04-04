RSpec.describe Experian::Client do

  around do |example|
    VCR.use_cassette("credit_report") do
      example.run
    end
  end

  describe ".initialize" do
    it "sets the configuration" do
      client = Experian::Client.new(user_code: 'user', password: 'password', base_uri: 'https://example.com')
      expect(client).to have_attributes(
        user_code: 'user',
        password: 'password',
        base_uri: 'https://example.com'
      )
    end
  end

  describe '.conn' do
    it 'sets timeout' do
      client = Experian::Client.new(request_timeout: 30)
      expect(client.send(:conn).options[:timeout]).to eq(30)
    end
  end

  describe "when it fails to calculate the CRC" do
    before do
      allow(SHA3::Digest).to receive(:hexdigest).and_raise(StandardError, "some error")
    end

    it "should raise an error" do
      expect { Experian::Client.new.credit_report(cif: "A18413302") }.to raise_error(Experian::Error, "Error calculating CRC: some error")
    end
  end
end