RSpec.describe Experian do
  it "has a version number" do
    expect(Experian::VERSION).to eq "0.1.3"
  end

  describe "#configure" do
    let(:user_code) { "U1234556" }
    let(:password) { "abcd1235" }
    let(:custom_base_uri) { "mochetts2233" }
    let(:custom_request_timeout) { 25 }

    before do
      Experian.configure do |config|
        config.user_code = user_code
        config.password = password
      end
    end

    it "returns the config" do
      expect(Experian.configuration.user_code).to eq(user_code)
      expect(Experian.configuration.password).to eq(password)
    end

    context "without a user_code" do
      let(:user_code) { nil }

      it "raises an error" do
        expect { Experian::Client.new.informe(cif: 'A18413302') }.to raise_error(Experian::ConfigurationError)
      end
    end

    context "with custom timeout and uri base" do
      before do
        Experian.configure do |config|
          config.base_uri = custom_base_uri
          config.request_timeout = custom_request_timeout
        end
      end

      it "returns the config" do
        expect(Experian.configuration.user_code).to eq(user_code)
        expect(Experian.configuration.password).to eq(password)
        expect(Experian.configuration.base_uri).to eq(custom_base_uri)
        expect(Experian.configuration.request_timeout).to eq(custom_request_timeout)
      end
    end

    context "when no password is set" do
      it "raises an exception" do
        Experian.configuration.password = nil
        expect { Experian.configuration.password }.to raise_error(Experian::ConfigurationError, "Experian password missing!")
      end
    end
  end
end