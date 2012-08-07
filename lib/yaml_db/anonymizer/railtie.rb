module YamlDb
  module Anonymizer
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load File.join(File.dirname(__FILE__), '..', '..', 'tasks', 'yaml_db_anonymizer.rake')
      end
    end
  end
end
