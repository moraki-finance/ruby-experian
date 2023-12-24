require "bundler/setup"
require "dotenv/load"
require "experian"
require "vcr"

Dir[File.expand_path("spec/support/**/*.rb")].sort.each { |f| require f }

VCR.configure do |c|
  c.hook_into :webmock
  c.cassette_library_dir = "spec/fixtures/cassettes"
  c.default_cassette_options = {
    record: ENV.fetch("EXPERIAN_USER_CODE", nil) ? :all : :new_episodes,
  }
  c.filter_sensitive_data("<EXPERIAN_USER_CODE>") { Experian.configuration.user_code }
  c.filter_sensitive_data("<EXPERIAN_PASSWORD>") { Experian.configuration.password }
end

RSpec.configure do |c|
  # Enable flags like --only-failures and --next-failure
  c.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  c.disable_monkey_patching!

  c.expect_with :rspec do |rspec|
    rspec.syntax = :expect
  end

  if ENV.fetch("EXPERIAN_USER_CODE", nil)
    warning = "WARNING! Specs are hitting the Experian API using your EXPERIAN_USER_CODE! This
costs at least 2 cents per run and is very slow! If you don't want this, unset
EXPERIAN_USER_CODE to just run against the stored VCR responses.".freeze
    warning = RSpec::Core::Formatters::ConsoleCodes.wrap(warning, :bold_red)

    c.before(:suite) { RSpec.configuration.reporter.message(warning) }
    c.after(:suite) { RSpec.configuration.reporter.message(warning) }
  end

  c.before(:all) do
    Experian.configure do |config|
      config.user_code = ENV.fetch("EXPERIAN_USER_CODE", "dummy-user")
      config.password = ENV.fetch("EXPERIAN_PASSWORD", "dummy-password")
    end
  end
end

RSPEC_ROOT = File.dirname __FILE__