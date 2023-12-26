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

      raise Experian::AuthenticationError if authentication_error?
    end

    def id
      if (id_xml = data["DatosIdentificativos"])
        OpenStruct.new(
          cif: id_xml["Cif"],
          name: id_xml["Nombre"],
          infotel_code: id_xml["CodigoInfotel"],
          incorporation_date: id_xml["FechaFundacion"],
          social_form: id_xml["FormaSocial"]["__content__"],
        )
      end
    end

    def address
      if (address_xml = data["DomicilioComercial"])
        OpenStruct.new(
          line: address_xml["Domicilio"],
          city: address_xml["Poblacion"],
          province: address_xml["Provincia"],
          postal_code: address_xml["CodigoPostal"],
          municipality: address_xml["Municipio"],
        )
      end
    end

    # Number of employees in the last recorded excercise
    def number_of_employees
      data.dig("ListaAnualEmpleados", "Empleado")&.first&.dig("EmpleadoFijo")&.to_i
    end

    def rating
      if (rating_xml = data["Rating"])
        return unless rating_xml["RatingAxesorDef"]

        OpenStruct.new(
          score: rating_xml["RatingAxesorDef"]&.strip&.to_i,
          default_probability: rating_xml["ProbImpago"]&.to_f,
          risk: rating_xml["GrupoRiesgo"],
          size: rating_xml["Tamaño"],
        )
      end
    end

    private

    def data
      xml.dig("ServicioWebAxesor", "ListaPaquetesNegocio")
    end

    def authentication_error?
      xml.dig("DatosError", "CodError") == "1"
    end
  end
end