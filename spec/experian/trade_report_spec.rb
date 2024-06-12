RSpec.describe Experian::TradeReport do
  let(:report) { Experian::Client.new.trade_report(cif: "A18413302") }

  around do |example|
    VCR.use_cassette("trade_report") do
      example.run
    end
  end

  before do
    allow(SHA3::Digest).to receive(:hexdigest).and_return("fake_crc")
  end

  describe "#model_200" do
    it "returns no values for last period" do
      expect(report.model_200).to match({
        "00041" => nil,
        "00042" => nil,
        "00101" => nil,
        "00102" => nil,
        "00136" => nil,
        "00138" => nil,
        "00149" => nil,
        "00177" => nil,
        "00180" => nil,
        "00185" => nil,
        "00210" => nil,
        "00216" => nil,
        "00228" => nil,
        "00231" => nil,
        "00239" => nil,
        "00255" => nil,
        "00260" => nil,
        "00265" => nil,
        "00284" => nil,
        "00285" => nil,
        "00286" => nil,
        "00287" => nil,
        "00295" => nil,
        "00296" => nil,
        "00305" => nil,
        "00326" => nil,
        "00327" => nil
      })
    end

    it "returns all the fields for 2021 model" do
      expect(report.model_200(period: 2021)).to match({
        "00041" => 144,
        "00042" => 1,
        "00101" => 10662579,
        "00102" => 5347259,
        "00136" => 5707152,
        "00138" => 0,
        "00149" => 4676426,
        "00177" => 819410,
        "00180" => 16369731,
        "00185" => 11475337,
        "00210" => 318655,
        "00216" => 318655,
        "00228" => 4575737,
        "00231" => 707370,
        "00239" => 1769605,
        "00255" => 4205095,
        "00260" => -536083,
        "00265" => 0,
        "00284" => -705142,
        "00285" => 0,
        "00286" => 0,
        "00287" => 0,
        "00295" => 20561,
        "00296" => 1075619,
        "00305" => -10187,
        "00326" => -227819,
        "00327" => 850990
      })
    end
  end

  it ".most_recent_number_of_employees" do
    expect(report.most_recent_number_of_employees).to eq(144)
  end

  it ".cnae" do
    expect(report.cnae).to eq(6311)
  end

  it ".constitution_date" do
    expect(report.constitution_date).to eq(Date.parse("08/03/1996"))
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

  it ".address" do
    expect(report.address).to have_attributes(
      line: "PARQUE EMPRESARIAL SAN ISIDRO, S/N - EDIFICIO AXESOR",
      city: "ARMILLA",
      province: "GRANADA",
      postal_code: nil, # comes as nil in the report
      municipality: "ARMILLA"
    )
  end
end