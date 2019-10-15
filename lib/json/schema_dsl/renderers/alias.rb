# frozen_string_literal: true

module JSON
  module SchemaDsl
    module Renderers
      # Aliases certain attributes and camel-cases all others.
      # The only exception are property names which are set by the user and
      # will not be camel-cased.
      class Alias < Base
        ALIASES = {
          'ref' => '$ref'
        }.freeze

        # Camel-case and/or alias the attribute names of the given structure.
        def visit(entity)
          traverse(entity
            .transform_keys { |key| ALIASES[key.to_s]&.to_sym || key }
            .transform_keys { |key| camelize_snake_cased(key) })
        end

        private

        def camelize_snake_cased(key)
          key = key.to_s
          (key.capitalize == key ? key : key.camelize(:lower)).to_sym
        end

        def traverse(entity)
          entity.map do |key, value|
            if key.to_s.match?(/properties$/i) && value.is_a?(Hash)
              [key, value.transform_values { |v| visit(v) }]
            else
              [key, step(value)]
            end
          end.to_h
        end
      end
    end
  end
end
