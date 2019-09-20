# frozen_string_literal: true

module JSON
  module SchemaDsl
    module Renderers
      class Multiplexer < Base
        class << self
          KEYS = %i[any_of one_of all_of].freeze

          def visit(entity)
            traverse(box(entity))
          end

          private

          def box(entity)
            present_key = entity[:type] != 'entity' && KEYS.find { |k| entity[k].present? }
            return entity unless present_key

            {
              type: 'entity',
              present_key => entity[present_key].map { |ch| visit(ch) }
            }
          end
        end
      end
    end
  end
end
