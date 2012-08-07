module YamlDb
  module Anonymizer
    module Helper
      class << self
        def dumper
          YamlDb::Anonymizer::Dump
        end

        def loader
          YamlDb::Load
        end

        def extension
          "yml"
        end
      end
    end
  end
end
