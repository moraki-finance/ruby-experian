RSpec.describe Experian::Client do
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

  describe "#report" do
    let(:report) { Experian::Client.new.report(cif:) }

    before do
      allow(SHA3::Digest).to receive(:hexdigest).and_return("fake_crc")
    end

    describe "axesor", :vcr do
      let(:cif) { "A18413302" }

      around do |example|
        VCR.use_cassette("axesor") do
          example.run
        end
      end

      it "uses the user & password to calculate the CRC" do
        report
        expect(SHA3::Digest).to have_received(:hexdigest).with(:sha256, "A18413302572fake_userfake_password")
      end

      it ".address" do
        expect(report.address).to have_attributes(
          line: "C/ GRAHAM BELL, Nº 1, POL. IND. SAN ISIDRO, EDIFICIO EXPERIAN",
          city: "ARMILLA",
          province: "GRANADA",
          postal_code: "18100",
          municipality: "ARMILLA"
        )
      end

      it ".rating" do
        allow(report).to receive(:data).and_return({
          "Rating" => {
            "RatingAxesorDef" => "8 ",
            "ProbImpago" => "0.56",
            "GrupoRiesgo" => "Bajo",
            "Tamaño" => "Grande"
          }
        })
        expect(report.rating).to have_attributes(
          score: 8,
          default_probability: 0.56,
          risk: "Bajo",
          size: "Grande",
        )
      end

      it ".number_of_employees" do
        expect(report.number_of_employees).to eq(144)
      end

      it ".id" do
        expect(report.id).to have_attributes(
          cif: "A18413302",
          name: "AXESOR CONOCER PARA DECIDIR SA",
          infotel_code: "987857",
          incorporation_date: "08/03/1996",
          social_form: "SOCIEDAD ANONIMA"
        )
      end

      it ".url" do
        expect(report.url).to eq("https://informes.axesor.es/informe?cif=A18413302&cod_servicio=57&tip_formato=2&cod_usuario=fake_user&crc=fake_crc")
      end
    end

    describe "wrong creds", :vrc do
      let(:cif) { "A18413302" }

      before do
        allow(SHA3::Digest).to receive(:hexdigest).and_return("wrong_crc")
      end

      around do |example|
        VCR.use_cassette("axesor") do
          example.run
        end
      end

      it "fails gracefully" do
        expect { report }.to raise_error(Experian::AuthenticationError)
      end
    end
  end
end