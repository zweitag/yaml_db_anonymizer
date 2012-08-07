require 'rubygems'
require 'spork'

Spork.prefork do
  require 'rspec'
  require 'bundler/setup'

end

Spork.each_run do
  require 'yaml_db_anonymizer'

end

