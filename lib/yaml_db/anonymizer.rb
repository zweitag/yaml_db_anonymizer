require 'yaml_db'

module YamlDb
  module Anonymizer
    autoload :Dump,    'yaml_db/anonymizer/dump'
    autoload :Helper,  'yaml_db/anonymizer/helper'
    autoload :VERSION, 'yaml_db/anonymizer/version'

    class << self
      attr_accessor :definition

      def define(*args, &block)
        self.definition = {}
        class_eval &block
      end

      def table(table_name, &block)
        @table_name = table_name.to_s
        self.definition[@table_name] = {}
        class_eval &block
      end

      def truncate
        self.definition[@table_name] = :truncate
      end

      def remove(column_name)
        self.definition[@table_name][column_name.to_s] = nil
      end

      def replace(column_name, opts={})
        self.definition[@table_name][column_name.to_s] = opts[:with]
      end

      def anonymize(table, column, value)
        return value unless self.definition.key?(table.to_s) and self.definition[table.to_s].key?(column.to_s)
        block_or_value = self.definition[table.to_s][column.to_s]
        block_or_value.is_a?(Proc) ? block_or_value.call(value) : block_or_value
      end
    end
  end
end
