source "https://rubygems.org"

# Include gem dependencies from ruby-experian.gemspec
gemspec

gem "dotenv", "~> 2.8.1"
gem "rake", "~> 13.1"
gem "rspec", "~> 3.13"
gem "rubocop", "~> 1.50.2"
gem "vcr", "~> 6.1.0"
gem "webmock", "~> 3.23.0"

group :development, :test do
  gem "byebug", "~> 11.1"
  gem "pry", "~> 0.14.2"
  gem "pry-byebug", "~> 3.10"
  gem "pry-rescue", "~> 1.6"
  gem "pry-stack_explorer", "~> 0.6.1"
end

group :test do
  gem "simplecov"
  gem "simplecov-cobertura"
end