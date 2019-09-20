# frozen_string_literal: true

module JSON
  module SchemaDsl
    module Renderers
      class Filter < Base
        class << self
          INVISIBLES = %w[Children Nullable Name].freeze

          def visit(entity)
            traverse(filter(entity))
          end

          private

          def filter(entity)
            entity
              .except(*(INVISIBLES + INVISIBLES.map(&:underscore).map(&:to_sym)))
              .transform_values { |v| presence_of(v, preserve: [false]) }
              .compact
          end

          def presence_of(obj, preserve: [])
            return obj if preserve.include? obj

            obj.presence
          end
        end
      end
    end
  end
end
