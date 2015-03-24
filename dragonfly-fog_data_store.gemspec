# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dragonfly/fog_data_store/version'

Gem::Specification.new do |spec|
  spec.name          = "dragonfly-fog_data_store"
  spec.version       = Dragonfly::FogDataStore::VERSION
  spec.authors       = ["Jimmy Hsu"]
  spec.email         = ["irregular.profit@gmail.com"]
  spec.description   = %q{Racksapce data store for Dragonfly}
  spec.summary       = %q{Data store for storing Dragonfly content Rackspace through Fog}
  spec.homepage      = "https://github.com/irregularprofit/dragonfly-fog_data_store"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "dragonfly", "~> 1.0"
  spec.add_runtime_dependency "fog"
  spec.add_development_dependency "rspec", "~> 2.0"
end
