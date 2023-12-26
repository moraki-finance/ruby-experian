module Experian
  class Client
    include Experian::HTTP

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

    def report(cif:, format: :xml)
      response = get(path: "/informe", format:, cif:, cod_servicio: 57)

      return Experian::Report.new(response) if format == :xml

      response
    end
  end
end
