require "multi_xml"
require "rexml"

module Experian
  class CreditReport < Report
    def id
      if (id_xml = data["DatosIdentificativos"])
        OpenStruct.new(
          cif: id_xml["Cif"],
          name: id_xml["Nombre"],
          infotel_code: id_xml["CodigoInfotel"],
          incorporation_date: Date.parse(id_xml["FechaFundacion"]),
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

    def cnae
      data.dig("ActividadComercial", "Cnae")&.first&.dig("Codigo")&.to_i
    end

    def constitution_date
      date = data.dig("DatosConstitutivos", "FechaConstitucion")
      date && Date.parse(date)
    end
  end
end