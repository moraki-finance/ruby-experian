module Experian
  class TradeReport < Report
    def model_200(period: last_submitted_year)
      {
        # Balance Sheet - Assets
        "00101" => financial_data("Activo", "11000", period:), # ACTIVO NO CORRIENTE
        "00102" => financial_data("Activo", "11100", period:), # Inmovilizado intangible
        "00136" => financial_data("Activo", "12000", period:), # ACTIVO CORRIENTE
        "00138" => financial_data("Activo", "12200", period:), # Existencias
        "00149" => financial_data("Activo", "12300", period:), # Deudores comerciales y otras cuentas a cobrar
        "00177" => financial_data("Activo", "12700", period:), # Efectivo y otros activos líquidos equivalentes
        "00180" => financial_data("Activo", "10000", period:), # TOTAL ACTIVO

        # Balance Sheet - Liabilities
        "00185" => financial_data("Pasivo", "20000", period:), # PATRIMONIO NETO
        "00210" => financial_data("Pasivo", "31000", period:), # PASIVO NO CORRIENTE
        "00216" => financial_data("Pasivo", "31200", period:), # Deudas a largo plazo
        "00228" => financial_data("Pasivo", "32000", period:), # PASIVO CORRIENTE
        "00231" => financial_data("Pasivo", "32300", period:), # Deudas a corto plazo
        "00239" => financial_data("Pasivo", "32500", period:), # Acreedores comerciales y otras cuentas a pagar

        # P&L
        "00255" => financial_data("PerdidasGanancias", "40100", period:), # Importe neto de la cifra de negocios
        "00260" => financial_data("PerdidasGanancias", "40400", period:), # Aprovisionamientos
        "00265" => financial_data("PerdidasGanancias", "40500", period:), # Otros ingresos de explotación
        "00284" => financial_data("PerdidasGanancias", "40800", period:), # Amortización del inmovilizado
        "00285" => financial_data("PerdidasGanancias", "40900", period:), # Imputación de subvenciones de inmovilizado no financiero y otras
        "00286" => financial_data("PerdidasGanancias", "41000", period:), # Excesos de provisiones
        "00287" => financial_data("PerdidasGanancias", "41100", period:), # Deterioro y resultado por enajenaciones del inmovilizad
        "00295" => financial_data("PerdidasGanancias", "41300", period:), # Otros resultados
        "00296" => financial_data("PerdidasGanancias", "49100", period:), # Resultado de explotacion
        "00305" => financial_data("PerdidasGanancias", "41500", period:), # Gastos Financieros
        "00326" => financial_data("PerdidasGanancias", "41900", period:), # Impuestos Sobre Beneficios
        "00327" => financial_data("PerdidasGanancias", "49500", period:), # RESULTADO DEL EJERCICIO PROCEDENTE DE OPERACIONES CONTINUADAS
      }
    end

    private

    def last_submitted_year
      (Date.today << 18).year
    end

    def financial_data(section_name, value_name, period:)
      value_section = section(section_name)

      if value_name
        value_section&.find { |d| d["Tipo"] == value_name }&.dig("ListaValores", "Valor")&.find { |v| v["Periodo"] == period.to_s }&.dig("Individual")&.to_i
      end
    end

    def section(section_name)
      data.dig("InformeEconomicoFinanciero")&.first&.dig("ListaGrupos", "Grupo").find { |d| d["Tipo"][section_name] }&.dig("ListaColumnas", "Columna", "ListaDatos", "Dato")
    end
  end
end