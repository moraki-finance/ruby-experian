module Experian
  class Report
    attr_reader :xml

    def initialize(xml)
      @xml = xml
    end

    def id
      id_xml = data["DatosIdentificativos"]
      OpenStruct.new(
        cif: id_xml["Cif"],
        name: id_xml["Nombre"],
        infotel_code: id_xml["CodigoInfotel"],
        incorporation_date: id_xml["FechaFundacion"],
        social_form: id_xml["FormaSocial"]["__content__"],
      )
    end

    def address
      address_xml = data["DomicilioComercial"]
      OpenStruct.new(
        line: address_xml["Domicilio"],
        city: address_xml["Poblacion"],
        province: address_xml["Provincia"],
        postal_code: address_xml["CodigoPostal"],
        municipality: address_xml["Municipio"],
      )
    end

    # Number of employees in the last recorded excercise
    def number_of_employees
      data["ListaAnualEmpleados"]["Empleado"].first["EmpleadoFijo"].to_i
    end

    def rating
      rating_xml = data["Rating"]
      OpenStruct.new(
        score: rating_xml["RatingAxesorDef"].strip.to_i,
        default_probability: rating_xml["ProbImpago"].to_f,
        risk: rating_xml["GrupoRiesgo"],
        size: rating_xml["Tamaño"],
      )
    end

    private

    def data
      xml["ServicioWebAxesor"]["ListaPaquetesNegocio"]
    end
  end
end