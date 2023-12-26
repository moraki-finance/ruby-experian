require "faraday"
require "faraday_middleware"

require_relative "experian/http"
require_relative "experian/client"
require_relative "experian/version"
require_relative "experian/report"

module Experian
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class ConfigurationError < Error; end

  class MiddlewareErrors < Faraday::Middleware
    def call(env)
      @app.call(env)
    rescue Faraday::Error => e
      raise e unless e.response.is_a?(Hash)

      logger = Logger.new($stdout)
      logger.formatter = proc do |_severity, _datetime, _progname, msg|
        "\033[31mExperian HTTP Error (spotted in ruby-experian #{VERSION}): #{msg}\n\033[0m"
      end
      logger.error(e.response[:body])

      raise e
    end
  end

  class Configuration
    attr_writer :user_code, :password, :version, :request_timeout, :base_uri
    attr_reader :base_uri, :request_timeout, :version

    DEFAULT_BASE_URI = "https://informes.axesor.es".freeze
    DEFAULT_VERSION = "9.0".freeze
    DEFAULT_REQUEST_TIMEOUT = 120

    def initialize
      @user_code = nil
      @password = nil
      @version = DEFAULT_VERSION
      @request_timeout = DEFAULT_REQUEST_TIMEOUT
      @base_uri = DEFAULT_BASE_URI
    end

    def user_code
      return @user_code if @user_code
      raise ConfigurationError, "Experian user_code missing!"
    end

    def password
      return @password if @password
      raise ConfigurationError, "Experian password missing!"
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Experian::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
