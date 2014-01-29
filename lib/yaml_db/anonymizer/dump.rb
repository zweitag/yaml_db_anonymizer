module YamlDb
  module Anonymizer
    class Dump < ::YamlDb::Dump

      def self.dump_table_records(io, table)
        return super(io, table) unless Anonymizer.definition.is_a? Hash
        return if Anonymizer.definition[table.to_s] == :truncate

        table_record_header(io)

        column_names = table_column_names(table)

        each_table_page(table) do |records|
          rows = SerializationHelper::Utils.unhash_records(records, column_names)
          records_anonymized = rows.map do |record|
            record.each_with_index.map do |value, i|
              Anonymizer.anonymize(table, column_names[i], value)
            end
          end
          io.write(YamlDb::Utils.chunk_records(records_anonymized))
        end
      end

      def self.dump_table_columns(io, table)
        super(io, table) unless Anonymizer.definition.is_a?(Hash) && Anonymizer.definition[table.to_s] == :truncate
      end

      def self.tables
        ActiveRecord::Base.connection.tables - tables_to_truncate
      end

      def self.tables_to_truncate
        Anonymizer.definition.select {|table_name, options| options == :truncate }.keys
      end
    end

  end
end

