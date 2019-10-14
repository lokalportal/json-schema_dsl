# frozen_string_literal: true

module JSON
  module SchemaDsl
    module Renderers
      class Base
        attr_reader :scope
        def initialize(scope)
          @scope = scope
        end

        def traverse(entity)
          entity.transform_values { |v| step(v) }
        end

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
