module DbSchema
  module Definitions
    class Index
      include Dry::Equalizer(:name, :columns, :primary?, :unique?, :type, :condition)
      attr_reader :name, :columns, :type, :condition

      def initialize(name:, columns:, primary: false, unique: false, type: :btree, condition: nil)
        @name      = name.to_sym
        @columns   = columns
        @primary   = primary
        @unique    = unique
        @type      = type
        @condition = condition
      end

      def primary?
        @primary
      end

      def unique?
        @unique
      end

      def btree?
        type == :btree
      end

      def columns_to_sequel
        if btree?
          columns.map(&:ordered_expression)
        else
          columns.map(&:to_sequel)
        end
      end

      def has_expressions?
        !condition.nil? || columns.any?(&:expression?)
      end

      def with_name(new_name)
        Index.new(
          name:      new_name,
          columns:   columns,
          primary:   primary?,
          unique:    unique?,
          type:      type,
          condition: condition
        )
      end

      def with_condition(new_condition)
        Index.new(
          name:      name,
          columns:   columns,
          primary:   primary?,
          unique:    unique?,
          type:      type,
          condition: new_condition
        )
      end
    end

    class NullIndex < Index
      def initialize
        @columns = []
      end
    end
  end
end

require_relative 'index/column'
require_relative 'index/table_field'
require_relative 'index/expression'
