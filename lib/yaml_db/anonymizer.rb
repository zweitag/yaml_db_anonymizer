require 'yaml_db'
require 'yaml_db/anonymizer/railtie'

module YamlDb
  module Anonymizer
    format_class = ENV['class'] || "YamlDb::Anonymizer::Helper"
    format_module = format_class.split('::').first.underscore

    autoload :Dump,    "#{format_module}/anonymizer/dump"
    autoload :Helper,  "#{format_module}/anonymizer/helper"
    autoload :VERSION, "#{format_module}/anonymizer/version"

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
        if block_or_value.is_a?(Proc)
          block_or_value.arity == 1 ? block_or_value.call(value) : block_or_value.call
        else
          block_or_value
        end
      end
    end
  end
end
