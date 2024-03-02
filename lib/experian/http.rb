require "base64"
require "sha3"

Faraday::FlatParamsEncoder.sort_params = false

module Experian
  module HTTP

    def get(path:, format:, **query)
      tip_formato = {
        xml: 2,
        pdf: 3
      }[format]

      raise Experian::Error, "Invalid format: #{format}" unless tip_formato

      query.merge!(tip_formato:)
      full_uri = uri(path:, query:)

      if format == :xml
        return conn.get(full_uri) do |req|
          req.headers = headers
        end
      end

      full_uri
    end

    private

    def conn
      connection = Faraday.new do |f|
        f.options[:timeout] = request_timeout
        f.options[:params_encoder] = Faraday::FlatParamsEncoder
        f.response :raise_error
      end

      @faraday_middleware&.call(connection)

      connection
    end

    def uri(path:, query: {})
      query[:cod_usuario] = user_code
      query[:crc] = crc(query)
      File.join(base_uri, path) + "?#{URI.encode_www_form(query)}"
    end

    def crc(query = {})
      SHA3::Digest.hexdigest(:sha256, query.values.join << password)
    rescue => e
      raise Experian::Error, "Error calculating CRC: #{e.message}"
    end

    def headers
      {}.merge(extra_headers)
    end
  end
end
