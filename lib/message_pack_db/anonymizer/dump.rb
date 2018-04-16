require 'message_pack_db'
require 'time'

module MessagePackDb
  module Anonymizer
    class Dump < ::MessagePackDb::Dump

      def self.dump_table_records(packer, table)
        return super(packer, table) unless YamlDb::Anonymizer.definition.is_a? Hash
        return if YamlDb::Anonymizer.definition[table.to_s] == :truncate

        column_names = table_column_names(table)

        each_table_page(table) do |records|
          rows = SerializationHelper::Utils.unhash_records(records, column_names)
          records_anonymized = rows.map do |record|
            record_anonymized = []
            record.each_with_index do |value, i|
              record_anonymized << YamlDb::Anonymizer.anonymize(table, column_names[i], value)
            end
            record_anonymized
          end
          packer.write records_anonymized
        end
      end

      def self.dump_table_header(packer, table)
        super(packer, table) unless YamlDb::Anonymizer.definition.is_a?(Hash) && YamlDb::Anonymizer.definition[table.to_s] == :truncate
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

