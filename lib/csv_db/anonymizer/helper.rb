module CsvDb
  module Anonymizer
    module Helper
      class << self
        def dumper
          CsvDb::Anonymizer::Dump
        end

        def loader
          CsvDb::Load
        end

        def extension
          "csv"
        end
      end
    end
  end
end
