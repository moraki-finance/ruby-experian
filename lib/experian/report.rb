require "multi_xml"
require "rexml"

module Experian
  class Report
    attr_reader :response, :url, :raw_xml, :xml

    def initialize(response)
      @response = response
      @url = response.env.url.to_s
      @raw_xml = response.body
      MultiXml.parser = :rexml
      @xml = MultiXml.parse(@raw_xml)

      raise error, error_message if error
    end

    protected

    def data
      xml.dig("ServicioWebAxesor", "ListaPaquetesNegocio")
    end

    def error
      return Experian::AuthenticationError if authentication_error?

      Experian::Error if any_other_error?
    end

    def error_message
      xml.dig("DatosError", "DesError")
    end

    def any_other_error?
      xml.dig("DatosError", "CodError")
    end

    def authentication_error?
      xml.dig("DatosError", "CodError") == "1"
    end
  end
end