# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_setting/version'

Gem::Specification.new do |spec|
  spec.name          = 'active_setting'
  spec.version       = ActiveSetting::VERSION
  spec.authors       = ["Michael Noack"]
  spec.email         = 'support@travellink.com.au'
  spec.description   = "See README for full details on how to install, use, etc."
  spec.summary       = "Store active_settings of various data types"
  spec.homepage      = 'http://github.com/sealink/active_setting'

  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.6'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'coverage-kit'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'pry-byebug'
end
