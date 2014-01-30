# -*- encoding: utf-8 -*-
require File.expand_path('../lib/yaml_db/anonymizer/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Thomas Hollstegge", 'Martin Honermeyer']
  gem.email         = ["thomas@hollstegge.net"]
  gem.description   = %q{Dumps anonymized database contents to .yml files}
  gem.summary       = %q{A database dumper with anonymization}
  gem.homepage      = "https://github.com/zweitag/yaml_db_anonymizer"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "yaml_db_anonymizer"
  gem.require_paths = ["lib"]
  gem.version       = YamlDb::Anonymizer::VERSION

  gem.add_dependency 'yaml_db_with_schema_tables', '~> 0.3.1'

  gem.add_development_dependency 'rspec', '~> 2.11.0'
  gem.add_development_dependency 'rails', '~> 3.2'
  gem.add_development_dependency 'guard-rspec', '~> 1.1.0'
  gem.add_development_dependency 'guard-spork', '~> 1.1.0'
end
