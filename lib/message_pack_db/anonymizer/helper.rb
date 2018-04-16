module MessagePackDb
  module Anonymizer
    module Helper
      class << self
        def dumper
          MessagePackDb::Anonymizer::Dump
        end

        def loader
          MessagePackDb::Load
        end

        def extension
          "mpk"
        end
      end
    end
  end
end
