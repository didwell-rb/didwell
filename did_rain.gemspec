# frozen_string_literal: true

require_relative "lib/did_rain/version"

Gem::Specification.new do |spec|
  spec.name = "did_rain"
  spec.version = DIDRain::VERSION
  spec.authors = ["merely"]
  spec.summary = "DID toolkit for Ruby"
  spec.description = "Ruby toolkit for Decentralized Identifiers (DIDs) — DIDComm messaging, and more"
  spec.homepage = "https://github.com/onyxblade/did_rain"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.0"

  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_dependency "zeitwerk", "~> 2.7"
  spec.add_dependency "rbnacl", "~> 7.1"
  spec.add_dependency "base58", "~> 0.2"
  spec.add_dependency "base64", ">= 0.2"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rake", "~> 13.0"
  # YARD documentation
  spec.add_development_dependency "yard", "~> 0.9"
  spec.add_development_dependency "redcarpet", "~> 3.6" # markdown markup
  spec.add_development_dependency "irb"                  # yard runtime dep, not default gem since Ruby 4.0
  spec.add_development_dependency "rdoc"                 # yard runtime dep, not default gem since Ruby 4.0
end
