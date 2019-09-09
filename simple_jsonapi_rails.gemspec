lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'simple_jsonapi/rails/version'

Gem::Specification.new do |spec|
  spec.name          = 'simple_jsonapi_rails'
  spec.version       = SimpleJsonapi::Rails::VERSION
  spec.license       = "MIT"
  spec.authors       = ['PatientsLikeMe']
  spec.email         = ['engineers@patientslikeme.com']
  spec.homepage      = 'https://www.patientslikeme.com'

  spec.summary       = 'A library for integrating SimpleJsonapi into a Rails application.'
  spec.description   = 'A library for integrating SimpleJsonapi into a Rails application.'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^test/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'simple_jsonapi'
  spec.add_runtime_dependency 'rails', '>= 4.2', '< 7.0'

  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'listen'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-reporters', '~> 1.1.11'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rails', '~> 5.1.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'will_paginate'
  spec.add_development_dependency 'yard'
end
