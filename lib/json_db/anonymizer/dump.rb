require 'json_db'

module JsonDb
  module Anonymizer
    class Dump < ::JsonDb::Dump
    
      def self.dump_table_records(io, table)
        return super(io, table) unless YamlDb::Anonymizer.definition.is_a? Hash
        return if YamlDb::Anonymizer.definition[table.to_s] == :truncate

        table_record_header(io)

        column_names = table_column_names(table)

        first_page = true
        each_table_page(table) do |records|
          rows = SerializationHelper::Utils.unhash_records(records, column_names)
          records_anonymized = rows.map do |record|
            record_anonymized = []
            record.each_with_index do |value, i|
              record_anonymized << YamlDb::Anonymizer.anonymize(table, column_names[i], value)
            end
            record_anonymized
          end
          io.write ', ' unless first_page
          first_page = false
          io.write JSON.dump(records_anonymized)[1..-2]      # without opening and closing brackets 
        end

        io.write ' ]'
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

