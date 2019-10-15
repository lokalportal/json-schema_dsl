# frozen_string_literal: true

module JSON
  module SchemaDsl
    module Renderers
      # Filters out properties that are either used internally only or
      # which are redundant (I.e. set to nil).
      class Filter < Base
        INVISIBLES = %w[Children Nullable Name].freeze

        # Filters out properties that are either used internally only or
        # which are redundant (I.e. set to nil).
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
