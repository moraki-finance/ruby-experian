module Experian
  class Client
    include Experian::HTTP

    TRADE_REPORT = 388
    CREDIT_REPORT = 57

    CONFIG_KEYS = %i[
      user_code password request_timeout base_uri extra_headers
    ].freeze
    attr_reader(*CONFIG_KEYS, :faraday_middleware)

    def initialize(config = {}, &faraday_middleware)
      CONFIG_KEYS.each do |key|
        # Set instance variables like api_type & access_token. Fall back to global config
        # if not present.
        instance_variable_set("@#{key}", config[key] || Experian.configuration.send(key))
      end
      @faraday_middleware = faraday_middleware
    end

    def credit_report(cif:, format: :xml, as_response: false)
      response = get(
        path: "/informe",
        format:,
        cif:,
        cod_servicio: CREDIT_REPORT
      )

      return Experian::CreditReport.new(response) if format == :xml && !as_response

      response
    end

    def trade_report(cif:, format: :xml, request_update: true, as_response: false)
      response = get(
        path: "/informe",
        format:,
        cif:,
        garantizar_bajo_demanda: request_update ? 1 : 0,
        cod_servicio: TRADE_REPORT,
      )

      return Experian::TradeReport.new(response) if format == :xml && !as_response

      response
    end
  end
end
