# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cryptic_archive/version'

Gem::Specification.new do |spec|
  spec.name          = "cryptic_archive"
  spec.version       = CrypticArchive::VERSION
  spec.authors       = ["Peter Wood"]
  spec.email         = ["pwood@blacknorth.com"]
  spec.summary       = %q{Ruby wrapper library for the Cryptic Archive REST API.}
  spec.description   = %q{This library provides wrapper functionality for interacting with the Cryptic Archive REST API, removing the need to directly interact via a HTTP library.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency "webmock", "~> 1.21"

  spec.add_dependency "json", "~> 1.8"
  spec.add_dependency "logjam", "~> 1.2"
  spec.add_dependency "rest-client", "~> 1.8"
end
