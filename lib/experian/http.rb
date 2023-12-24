require "base64"
require "sha3"
require "byebug"

module Experian
  module HTTP
    module FlatParamsEncoder
      class << self
        extend Forwardable
        def_delegators :'Faraday::Utils', :escape, :unescape
      end

      def self.encode(params)
        return nil if params == nil

        if !params.is_a?(Array)
          if !params.respond_to?(:to_hash)
            raise TypeError,
              "Can't convert #{params.class} into Hash."
          end
          params = params.to_hash
          params = params.map do |key, value|
            key = key.to_s if key.kind_of?(Symbol)
            [key, value]
          end
        end

        # The params have form [['key1', 'value1'], ['key2', 'value2']].
        buffer = ''
        params.each do |key, value|
          encoded_key = escape(key)
          value = value.to_s if value == true || value == false
          if value == nil
            buffer << "#{encoded_key}&"
          elsif value.kind_of?(Array)
            value.each do |sub_value|
              encoded_value = escape(sub_value)
              buffer << "#{encoded_key}=#{encoded_value}&"
            end
          else
            encoded_value = escape(value)
            buffer << "#{encoded_key}=#{encoded_value}&"
          end
        end
        return buffer.chop
      end

      def self.decode(query)
        empty_accumulator = {}
        return nil if query == nil
        split_query = (query.split('&').map do |pair|
          pair.split('=', 2) if pair && !pair.empty?
        end).compact
        return split_query.inject(empty_accumulator.dup) do |accu, pair|
          pair[0] = unescape(pair[0])
          pair[1] = true if pair[1].nil?
          if pair[1].respond_to?(:to_str)
            pair[1] = unescape(pair[1].to_str.gsub(/\+/, " "))
          end
          if accu[pair[0]].kind_of?(Array)
            accu[pair[0]] << pair[1]
          elsif accu[pair[0]]
            accu[pair[0]] = [accu[pair[0]], pair[1]]
          else
            accu[pair[0]] = pair[1]
          end
          accu
        end
      end
    end

    def get(path:, format:, **query)
      tip_formato = {
        xml: 2,
        pdf: 3
      }[format]

      raise Experian::Error, "Invalid format: #{format}" unless tip_formato

      query.merge!(tip_formato:)
      full_uri = uri(path:, query:)

      return conn.get(full_uri) if format == :xml

      full_uri
    end

    private

    def conn(response_format: :xml)
      connection = Faraday.new do |f|
        f.options[:timeout] = request_timeout
        f.options[:params_encoder] = FlatParamsEncoder
        f.use MiddlewareErrors
        f.response :raise_error
        f.response response_format
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
  end
end
