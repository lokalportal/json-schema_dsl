# frozen_string_literal: true

module JSON
  module SchemaDsl
    module Renderers
      class Base
        class << self
          def traverse(entity)
            entity.transform_values do |value|
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
  end
end