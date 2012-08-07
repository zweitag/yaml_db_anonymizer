# -*- encoding: utf-8 -*-
require File.expand_path('../lib/yaml_db_anonymizer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Thomas Hollstegge"]
  gem.email         = ["thomas.hollstegge@zweitag.de"]
  gem.description   = %q{A database dumper with anonymization}
  gem.summary       = %q{A database dumper with anonymization}
  gem.homepage      = "https://github.com/Tho85/yaml_db_anonymizer"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "yaml_db_anonymizer"
  gem.require_paths = ["lib"]
  gem.version       = YamlDbAnonymizer::VERSION

  gem.add_development_dependency 'rspec', '~> 2.11.0'
  gem.add_development_dependency 'guard-rspec', '~> 1.1.0'
  gem.add_development_dependency 'guard-spork', '~> 1.1.0'
end
