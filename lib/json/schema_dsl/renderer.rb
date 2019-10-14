# frozen_string_literal: true

%w[base desugar multiplexer alias filter].each do |file|
  require "json/schema_dsl/renderers/#{file}"
end

module JSON
  module SchemaDsl
    class Renderer
      attr_reader :entity, :scope

      def initialize(entity, scope = nil)
        @entity = entity.to_h
        @scope = scope
      end

      def self.render(entity)
        new(entity).render
      end

      def render
        render_chain.inject(entity) do |structure, renderer|
          renderer.new(scope).visit(structure)
        end
      end

      private

      def render_chain
        ::JSON::SchemaDsl.registered_renderers
      end
    end
  end
end
