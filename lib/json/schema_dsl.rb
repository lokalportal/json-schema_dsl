# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'active_support/core_ext/object'
require 'docile'
require 'dry-struct'
require 'dry-types'

require 'json/schema_dsl/version'
require 'json/schema_dsl/types'
require 'json/schema_dsl/configuration'
require 'json/schema_dsl/entity'

%w[null boolean numeric integer string object array].each do |type|
  require "json/schema_dsl/#{type}"
end

require 'json/schema_dsl/builder'
require 'json/schema_dsl/renderer'
require 'json/schema_dsl/dsl'

module JSON
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

      def registered_renderers
        @registered_renderers ||= DEFAULT_RENDERERS.dup
      end

      def reset_registered_renderers!
        @registered_renderers = DEFAULT_RENDERERS.dup
      end

      def registered_types
        @registered_types ||= DEFAULT_TYPES.dup
      end

      def register_type(type)
        registered_types.push(type).tap { define_type_methods(type) }
      end

      def reset_schema_dsl!
        (registered_types.map { |t| type_method_name(t).to_sym } & instance_methods)
          .each { |tm| remove_method tm }
        @registered_types = DEFAULT_TYPES.dup
        define_schema_dsl!
      end

      def define_schema_dsl!
        registered_types.map { |t| define_type_methods(t) }
      end

      def define_type_methods(type)
        JSON::SchemaDsl::Builder.define_builder_method(type)
        builder = JSON::SchemaDsl::Builder[type]
        define_method(type_method_name(type)) do |name = nil, **attributes, &block|
          builder.build(name, **attributes, scope: self, &block)
        end
      end

      def type_method_name(type)
        type.type_method_name || 'entity'
      end
    end

    define_schema_dsl!
  end
end
