# Ruby Experian

<a href="https://codecov.io/github/moraki-finance/ruby-experian" >
 <img src="https://codecov.io/github/moraki-finance/ruby-experian/graph/badge.svg?token=SKTT14JJGV"/>
</a>

[![Tests](https://github.com/moraki-finance/ruby-experian/actions/workflows/tests.yml/badge.svg?branch=main)](https://github.com/moraki-finance/ruby-experian/actions/workflows/tests.yml)

Use the [Experian Axesor Informe 360](https://www.axesor.es/informacion-empresas/informes/informe-axesor-360.aspx) API with Ruby! 🩵

Allows you to get a detailed credit risk report for Spanish companies.

### Bundler

Add this line to your application's Gemfile:

```ruby
gem "ruby-experian"
```

And then execute:

```bash
$ bundle install
```

### Gem install

Or install with:

```bash
$ gem install ruby-experian
```

and require with:

```ruby
require "experian"
```

## Usage

- Get your user_code and password from [https://axesor.es](https://www.axesor.es/)

### Quickstart

For a quick test you can pass your user code and password directly to a new client:

```ruby
client = Experian::Client.new(user_code: "user code goes here", password: "password goes here")
```

### With Config

For a more robust setup, you can configure the gem with your API keys, for example in an `experian.rb` initializer file. Never hardcode secrets into your codebase - instead use something like [dotenv](https://github.com/motdotla/dotenv) to pass the keys safely into your environments.

```ruby
Experian.configure do |config|
    config.user_code = ENV.fetch("EXPERIAN_USER_CODE")
    config.password = ENV.fetch("EXPERIAN_PASSWORD")
end
```

Then you can create a client like this:

```ruby
client = Experian::Client.new
```

You can still override the config defaults when making new clients; any options not included will fall back to any global config set with `Experian.configure`. e.g. in this example the base_uri, request_timeout, etc. will fallback to any set globally using `Experian.configure`, with only the password overridden:

```ruby
client = Experian::Client.new(password: "some other password")
```

#### Custom timeout or base URI

The default timeout for any request using this library is 120 seconds. You can change that by passing a number of seconds to the `request_timeout` when initializing the client. You can also change the base URI used for all requests, eg. to use observability tools like [Helicone](https://docs.helicone.ai/quickstart/integrate-in-one-line-of-code).

```ruby
client = Experian::Client.new(
    user_code: "user code goes here",
    base_uri: "https://oai.hconeai.com/",
    request_timeout: 240,
    extra_headers: {
      "Helicone-Auth": "Bearer HELICONE_API_KEY"
      "helicone-stream-force-format" => "true",
    }
)
```

or when configuring the gem:

```ruby
Experian.configure do |config|
    config.user_code = ENV.fetch("EXPERIAN_USER_CODE")
    config.password = ENV.fetch("EXPERIAN_PASSWORD")
    config.base_uri = "https://oai.hconeai.com/" # Optional
    config.request_timeout = 240 # Optional
    config.extra_headers = {
      "Helicone-Auth": "Bearer HELICONE_API_KEY"
    } # Optional
end
```

#### Extra Headers per Client

You can dynamically pass headers per client object, which will be merged with any headers set globally with `Experian.configure`:

```ruby
client = Experian::Client.new(user_code: "code goes here", password: "password goes here")
client.add_headers("X-Proxy-TTL" => "43200")
```

#### Verbose Logging

You can pass [Faraday middleware](https://lostisland.github.io/faraday/#/middleware/index) to the client in a block, eg. to enable verbose logging with Ruby's [Logger](https://ruby-doc.org/3.2.2/stdlibs/logger/Logger.html):

```ruby
  client = Experian::Client.new do |f|
    f.response :logger, Logger.new($stdout), bodies: true
  end
```

### Report

You can hit the report api to get the 360 credit report from Experian by passing in a CIF to the call. Note that only some sections of the report are exposed. Other sections will be exposed as needed / requested.

The exposed sections for now are:

- id
- address
- rating
- number_of_employees

```ruby
report = client.report(cif: "cif goes here")
report.rating.inspect
# => "#<OpenStruct score=8, default_probability=0.529, risk=\"Mínimo\", size=\"Grande\">"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Warning

If you have an `EXPERIAN_USER_CODE` and `EXPERIAN_PASSWORD` in your `ENV`, running the specs will use this to run the specs against the actual API, which will be slow! Remove it from your environment with `unset` or similar if you just want to run the specs against the stored VCR responses.

## Release

In order to release this gem, you'll need the `gem-release` gem globally installed:

```bash
gem install gem-release
```

Second, run the specs without VCR so they actually hit the API. Set `EXPERIAN_USER_CODE` and `EXPERIAN_PASSWORD` in your environment or pass it in like this:

```
EXPERIAN_USER_CODE=code EXPERIAN_PASSWORD=password bundle exec rspec
```

Then update the version number in `version.rb`, update `CHANGELOG.md`, run `bundle install` to update Gemfile.lock, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/moraki-finance/ruby-experian>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/moraki-finance/ruby-experian/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ruby Experian project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/moraki-finance/ruby-experian/blob/main/CODE_OF_CONDUCT.md).
