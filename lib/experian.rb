require "faraday"

require_relative "experian/http"
require_relative "experian/client"
require_relative "experian/version"
require_relative "experian/report"
require_relative "experian/credit_report"
require_relative "experian/trade_report"

module Experian
  class Error < StandardError; end
  class AuthenticationError < Error; end
  class ConfigurationError < Error; end

  class Configuration
    attr_writer :user_code, :password, :version, :request_timeout, :base_uri, :extra_headers
    attr_reader :base_uri, :request_timeout, :version, :extra_headers

    DEFAULT_BASE_URI = "https://informes.axesor.es".freeze
    DEFAULT_VERSION = "9.0".freeze
    DEFAULT_REQUEST_TIMEOUT = 120

    def initialize
      @user_code = ENV.fetch("EXPERIAN_USER_CODE", nil)
      @password = ENV.fetch("EXPERIAN_PASSWORD", nil)
      @version = DEFAULT_VERSION
      @request_timeout = DEFAULT_REQUEST_TIMEOUT
      @base_uri = DEFAULT_BASE_URI
      @extra_headers = {}
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
