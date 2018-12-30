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
          when ::DbSchema::Definitions::Field::Custom
            :dbschema_definitions_custom_field
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
        def awesome_dbschema_definitions_schema(object)
          data = ["tables: #{object.tables.ai}"]
          data << "enums: #{object.enums.ai}" if object.enums.any?
          data << "extensions: #{object.extensions.ai}" if object.extensions.any?

          data_string = data.join(', ')
          "#<DbSchema::Definitions::Schema #{data_string}>"
        end

        def awesome_dbschema_definitions_null_object(object)
          "#<#{object.class}>"
        end

        def awesome_dbschema_definitions_table(object)
          data = ["fields: #{object.fields.ai}"]
          data << "indexes: #{object.indexes.ai}" if object.indexes.any?
          data << "checks: #{object.checks.ai}" if object.checks.any?
          data << "foreign_keys: #{object.foreign_keys.ai}" if object.foreign_keys.any?

          data_string = indent_lines(data.join(', '))
          "#<DbSchema::Definitions::Table #{object.name.ai} #{data_string}>"
        end

        def awesome_dbschema_definitions_field(object)
          options = object.options.map do |k, v|
            key = colorize("#{k}:", :symbol)

            if (k == :default) && v.is_a?(Symbol)
              "#{key} #{colorize(v.to_s, :string)}"
            else
              "#{key} #{v.ai}"
            end
          end.unshift(nil).join(', ')

          "#<#{object.class} #{object.name.ai}#{options}>"
        end

        def awesome_dbschema_definitions_custom_field(object)
          options = object.options.map do |k, v|
            key = colorize("#{k}:", :symbol)

            if (k == :default) && v.is_a?(Symbol)
              "#{key} #{colorize(v.to_s, :string)}"
            else
              "#{key} #{v.ai}"
            end
          end.unshift(nil).join(', ')

          "#<DbSchema::Definitions::Field::Custom (#{object.type.ai}) #{object.name.ai}#{options}>"
        end

        def awesome_dbschema_definitions_index(object)
          columns = format_dbschema_fields(object.columns)
          using = ' using ' + colorize(object.type.to_s, :symbol) unless object.btree?

          data = [nil]
          data << colorize('primary key', :nilclass) if object.primary?
          data << colorize('unique', :nilclass) if object.unique?
          data << colorize('condition: ', :symbol) + object.condition.ai unless object.condition.nil?

          "#<#{object.class} #{object.name.ai} on #{columns}#{using}#{data.join(', ')}>"
        end

        def awesome_dbschema_definitions_index_column(object)
          data = [object.name.ai]

          if object.desc?
            data << colorize('desc', :nilclass)
            data << colorize('nulls last', :symbol) if object.nulls == :last
          else
            data << colorize('nulls first', :symbol) if object.nulls == :first
          end

          data.join(' ')
        end

        def awesome_dbschema_definitions_check_constraint(object)
          "#<#{object.class} #{object.name.ai} #{object.condition.ai}>"
        end

        def awesome_dbschema_definitions_foreign_key(object)
          fields = format_dbschema_fields(object.fields)
          references = "#{colorize('references', :class)} #{object.table.ai}"
          references << ' ' + format_dbschema_fields(object.keys) unless object.references_primary_key?

          data = [nil]
          data << colorize("on_update:", :symbol) + " #{object.on_update.ai}" unless object.on_update == :no_action
          data << colorize("on_delete:", :symbol) + " #{object.on_delete.ai}" unless object.on_delete == :no_action
          data << colorize('deferrable', :nilclass) if object.deferrable?

          "#<#{object.class} #{object.name.ai} on #{fields} #{references}#{data.join(', ')}>"
        end

        def awesome_dbschema_definitions_enum(object)
          values = object.values.map do |value|
            colorize(value.to_s, :string)
          end.join(', ')

          "#<#{object.class} #{object.name.ai} (#{values})>"
        end

        def awesome_dbschema_definitions_extension(object)
          "#<#{object.class} #{object.name.ai}>"
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
