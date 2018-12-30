begin
  require 'awesome_print'
rescue LoadError
end

if defined?(AwesomePrint)
  module AwesomePrint
    module DbSchema
      module Definitions
        def self.included(base)
          base.send :alias_method, :cast_without_dbschema_definitions, :cast
          base.send :alias_method, :cast, :cast_with_dbschema_definitions
        end

        def cast_with_dbschema_definitions(object, type)
          case object
          when ::DbSchema::Definitions::Schema
            :dbschema_definitions_schema
          when ::DbSchema::Definitions::NullTable,
               ::DbSchema::Definitions::NullField,
               ::DbSchema::Definitions::NullIndex,
               ::DbSchema::Definitions::NullCheckConstraint,
               ::DbSchema::Definitions::NullForeignKey,
               ::DbSchema::Definitions::NullEnum
            :dbschema_definitions_null_object
          when ::DbSchema::Definitions::Table
            :dbschema_definitions_table
          when ::DbSchema::Definitions::Field::Base
            :dbschema_definitions_field
          when ::DbSchema::Definitions::Index
            :dbschema_definitions_index
          when ::DbSchema::Definitions::Index::Column
            :dbschema_definitions_index_column
          when ::DbSchema::Definitions::CheckConstraint
            :dbschema_definitions_check_constraint
          when ::DbSchema::Definitions::ForeignKey
            :dbschema_definitions_foreign_key
          when ::DbSchema::Definitions::Enum
            :dbschema_definitions_enum
          when ::DbSchema::Definitions::Extension
            :dbschema_definitions_extension
          else
            cast_without_dbschema_definitions(object, type)
          end
        end

      private
        def awesome_dbschema_definitions_schema(schema)
          data = ["tables: #{schema.tables.ai}"]
          data << "enums: #{schema.enums.ai}" if schema.enums.any?
          data << "extensions: #{schema.extensions.ai}" if schema.extensions.any?

          data_string = data.join(', ')
          "#<DbSchema::Definitions::Schema #{data_string}>"
        end

        def awesome_dbschema_definitions_null_object(object)
          "#<#{object.class}>"
        end

        def awesome_dbschema_definitions_table(table)
          data = ["fields: #{table.fields.ai}"]
          data << "indexes: #{table.indexes.ai}" if table.indexes.any?
          data << "checks: #{table.checks.ai}" if table.checks.any?
          data << "foreign_keys: #{table.foreign_keys.ai}" if table.foreign_keys.any?

          data_string = indent_lines(data.join(', '))
          "#<DbSchema::Definitions::Table #{table.name.ai} #{data_string}>"
        end

        def awesome_dbschema_definitions_field(field)
          options = field.options.map do |k, v|
            key = colorize("#{k}:", :symbol)

            if (k == :default) && v.is_a?(Symbol)
              "#{key} #{colorize(v.to_s, :string)}"
            else
              "#{key} #{v.ai}"
            end
          end.unshift(nil).join(', ')

          if field.custom?
            "#<DbSchema::Definitions::Field::Custom (#{field.type.ai}) #{field.name.ai}#{options}>"
          else
            "#<#{field.class} #{field.name.ai}#{options}>"
          end
        end

        def awesome_dbschema_definitions_index(index)
          columns = format_dbschema_fields(index.columns)
          using = ' using ' + colorize(index.type.to_s, :symbol) unless index.btree?

          data = [nil]
          data << colorize('primary key', :nilclass) if index.primary?
          data << colorize('unique', :nilclass) if index.unique?
          data << colorize('condition: ', :symbol) + index.condition.ai unless index.condition.nil?

          "#<#{index.class} #{index.name.ai} on #{columns}#{using}#{data.join(', ')}>"
        end

        def awesome_dbschema_definitions_index_column(column)
          data = [column.name.ai]

          if column.desc?
            data << colorize('desc', :nilclass)
            data << colorize('nulls last', :symbol) if column.nulls == :last
          else
            data << colorize('nulls first', :symbol) if column.nulls == :first
          end

          data.join(' ')
        end

        def awesome_dbschema_definitions_check_constraint(check)
          "#<#{check.class} #{check.name.ai} #{check.condition.ai}>"
        end

        def awesome_dbschema_definitions_foreign_key(fkey)
          fields = format_dbschema_fields(fkey.fields)
          references = "#{colorize('references', :class)} #{fkey.table.ai}"
          references << ' ' + format_dbschema_fields(fkey.keys) unless fkey.references_primary_key?

          data = [nil]
          data << colorize("on_update:", :symbol) + " #{fkey.on_update.ai}" unless fkey.on_update == :no_action
          data << colorize("on_delete:", :symbol) + " #{fkey.on_delete.ai}" unless fkey.on_delete == :no_action
          data << colorize('deferrable', :nilclass) if fkey.deferrable?

          "#<#{fkey.class} #{fkey.name.ai} on #{fields} #{references}#{data.join(', ')}>"
        end

        def awesome_dbschema_definitions_enum(enum)
          values = enum.values.map do |value|
            colorize(value.to_s, :string)
          end.join(', ')

          "#<#{enum.class} #{enum.name.ai} (#{values})>"
        end

        def awesome_dbschema_definitions_extension(extension)
          "#<#{extension.class} #{extension.name.ai}>"
        end

        def format_dbschema_fields(fields)
          if fields.one?
            fields.first.ai
          else
            '[' + fields.map(&:ai).join(', ') + ']'
          end
        end

        def indent_lines(text, indent_level = 4)
          text.gsub(/(?<!\A)^/, ' ' * indent_level)
        end
      end
    end
  end

  AwesomePrint::Formatter.send(:include, AwesomePrint::DbSchema::Definitions)
end
