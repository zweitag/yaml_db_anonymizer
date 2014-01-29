module JsonDb
  module Anonymizer
    module Helper
      class << self
        def dumper
          JsonDb::Anonymizer::Dump
        end

        def loader
          JsonDb::Load
        end

        def extension
          "json"
        end
      end
    end
  end
end
