require_relative "lib/experian/version"

Gem::Specification.new do |s|
  s.name                  = "ruby-experian"
  s.version               = Experian::VERSION
  s.summary               = "Experian Axesor client"
  s.description           = "Experian Axesor (https://www.axesor.es/informacion-empresas/informes/informe-axesor-360.aspx) client for ruby"
  s.authors               = ["Martin Mochetti"]
  s.email                 = "martin@moraki.co"
  s.files                 = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  s.required_ruby_version = Gem::Requirement.new(">= 2.6.0")
  s.homepage              = "https://github.com/moraki-finance/ruby-experian"
  s.license               = "MIT"
  s.bindir                = "bin"
  s.executables           = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths         = ["lib"]

  s.add_dependency "faraday", ">= 1"
  s.add_dependency "sha3", ">= 1"
  s.add_dependency "multi_xml", ">= 0.6.0"
  s.add_dependency "rexml", ">= 3.2"
end