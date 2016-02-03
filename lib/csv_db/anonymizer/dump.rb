require 'csv_db'

module CsvDb
  module Anonymizer
    class Dump < ::CsvDb::Dump

      def self.dump_table_records(io, table)
        return super(io, table) unless YamlDb::Anonymizer.definition.is_a? Hash
        return if YamlDb::Anonymizer.definition[table.to_s] == :truncate

        column_names = table_column_names(table)

        each_table_page(table) do |records|
          rows = SerializationHelper::Utils.unhash_records(records, column_names)
          records.each do |record|
            record_anonymized = []
            record.each_with_index do |value, i|
              record_anonymized << YamlDb::Anonymizer.anonymize(table, column_names[i], value.last)
            end
            io.write record_anonymized.to_csv
          end
        end
      end

      def self.dump_table_columns(io, table)
        super(io, table) unless YamlDb::Anonymizer.definition.is_a?(Hash) && YamlDb::Anonymizer.definition[table.to_s] == :truncate
      end

      def self.tables
        ActiveRecord::Base.connection.tables - tables_to_truncate
      end

      def self.tables_to_truncate
        YamlDb::Anonymizer.definition.select {|table_name, options| options == :truncate }.keys
      end
    end

  end
end

