# frozen_string_literal: true

module JSON
  module SchemaDsl
    module Renderers
      # The abstract base renderer that provides common behaviour
      # to all renderers like the depth-first-traversal and
      # access to the scope.
      # @abstract
      class Base
        attr_reader :scope
        # @param [Object] scope The scope used as a fallback for helper methods.
        def initialize(scope)
          @scope = scope
        end

        # @param [Hash] entity The entity-structure given as a tree.
        #   This method will recursively visit each value in the structure until
        #   all have been visited.
        # @return [Hash] The hash-tree with all values visited.
        def traverse(entity)
          entity.transform_values { |v| step(v) }
        end

        protected

        # @param [Object] value The value that should be visited. Behaves differently
        #   for each renderer, since #visit holds the core logic of each.
        # @return [Object] The visited object.
        def step(value)
          case value
          when ::Array
            value.first.is_a?(Hash) ? value.map { |v| visit(v) } : value
          when Hash then visit(value)
          else value
          end
        end
      end
    end
  end
end
