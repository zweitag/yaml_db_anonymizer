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
            # FIXME Why isn't there a map_with_index?
            record_anonymized = []
            record.each_with_index do |value, i|
              record_anonymized << Anonymizer.anonymize(table, column_names[i], value)
            end
            record_anonymized
          end
          io.write(YamlDb::Utils.chunk_records(records_anonymized))
        end
      end

      def self.dump_table_columns(io, table)
        super(io, table) unless Anonymizer.definition.is_a?(Hash) && Anonymizer.definition[table.to_s] == :truncate
      end

      def self.tables
        ActiveRecord::Base.connection.tables
      end

    end

  end
end

