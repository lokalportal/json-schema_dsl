# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'active_support/core_ext/object'
require 'docile'
require 'dry-struct'
require 'dry-types'

require 'json/schema_dsl/version'
require 'json/schema_dsl/types'
require 'json/schema_dsl/configuration'
require 'json/schema_dsl/ast_node'
require 'json/schema_dsl/entity'

%w[null boolean numeric integer string object array].each do |type|
  require "json/schema_dsl/#{type}"
end

require 'json/schema_dsl/builder'
require 'json/schema_dsl/renderer'

module JSON
  # This module provides the base that it includes with the methods to build new json-schemas.
  module SchemaDsl
    class Error < StandardError; end

    class << self
      delegate(:type_defaults,
               :reset_type_defaults!,
               :add_defaults_for,
               to: ::JSON::SchemaDsl::Builder)

      DEFAULT_TYPES = JSON::SchemaDsl::Entity
                      .descendants.dup.push(JSON::SchemaDsl::Entity).freeze
      DEFAULT_RENDERERS = [Renderers::Desugar,
                           Renderers::Multiplexer,
                           Renderers::Alias,
                           Renderers::Filter].freeze

      attr_writer :registered_renderers

      # @return [Array<Class>] The renderer classes that schema_dsl will use in the renderer
      def registered_renderers
        @registered_renderers ||= DEFAULT_RENDERERS.dup
      end

      # Resets the registered_renderers to the default settings
      # @return [Array<Class>] The renderer classes that schema_dsl will use in the renderer
      def reset_registered_renderers!
        @registered_renderers = DEFAULT_RENDERERS.dup
      end

      # @return [Array<Class>] The registered types. These are used to add new dsl
      #   and builder methods.
      def registered_types
        @registered_types ||= DEFAULT_TYPES.dup
      end

      # @param [Class] type A new type to be registered. This will define new builder and dsl
      #   methods for that type.
      # @return [Array<Class>] The registered types.
      def register_type(type)
        registered_types.push(type).tap { define_type_methods(type) }
      end

      # Resets schema_dsl back to default. Removes all dsl methods and redefines
      #   them with the default types.
      def reset_schema_dsl!
        (registered_types.map { |t| type_method_name(t).to_sym } & instance_methods)
          .each { |tm| remove_method tm }
        @registered_types = DEFAULT_TYPES.dup
        define_schema_dsl!
      end

      # Defines the dsl for all registered types.
      def define_schema_dsl!
        registered_types.map { |t| define_type_methods(t) }
      end

      # Defines builder methods for the given type.
      # @param [Class] type A class that is a {JSON::SchemaDsl::AstNode}
      def define_type_methods(type)
        JSON::SchemaDsl::Builder.define_builder_method(type)
        builder = JSON::SchemaDsl::Builder[type]
        define_method(type_method_name(type)) do |name = nil, **attributes, &block|
          builder.build(name, **attributes, scope: self, &block)
        end
      end

      # Reset all settings to default.
      def reset!
        reset_registered_renderers!
        reset_type_defaults!
        reset_schema_dsl!
      end

      # @param [Class] type The class for which a method will be defined.
      # @return [String] the name of the new method.
      def type_method_name(type)
        type.type_method_name || 'entity'
      end
    end

    define_schema_dsl!
  end
end
