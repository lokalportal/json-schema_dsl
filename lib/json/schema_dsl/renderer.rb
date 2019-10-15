# frozen_string_literal: true

%w[base desugar multiplexer alias filter].each do |file|
  require "json/schema_dsl/renderers/#{file}"
end

module JSON
  module SchemaDsl
    # Main entry point for the rendering chain of JSON::SchemaDsl.
    #
    # This will in turn apply the registered renderers one by one, updating the
    # entity-tree to result in json-schema.
    class Renderer
      attr_reader :entity, :scope

      # @param [Entity] entity The root entity-tree of this render run.
      # @param [Object] scope Used as a fallback for renderers that need access
      #   to helper methods.
      def initialize(entity, scope = nil)
        @entity = entity.to_h
        @scope = scope
      end

      # @see #render
      def self.render(entity)
        new(entity).render
      end

      # Applies the renderer chain in turn to produce valid json-schema.
      # Each renderer traverses the whole tree before passing the resulting structure to
      # the next renderer
      # @return [Hash] The resulting json schema structure after each render is applied.
      def render
        render_chain.inject(entity) do |structure, renderer|
          renderer.new(scope).visit(structure)
        end
      end

      private

      # @return [Array<Class>] Each rendering class that will be applied to the given entity.
      # @see ::JSON::SchemaDsl.registered_renderers
      def render_chain
        ::JSON::SchemaDsl.registered_renderers
      end
    end
  end
end
