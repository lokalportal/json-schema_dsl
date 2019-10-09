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

            new_value = entity[present_key].map { |ch| visit(ch) }
            new_value.push(entity.except(present_key)) unless container?(entity.except(present_key))

            { type: 'entity', present_key => new_value.reject(&:blank?) }
          end

          def container?(entity)
            cleaned_up = Renderers::Filter.visit(entity)

            cleaned_up[:type].to_s == 'object' && cleaned_up.keys.count <= 1
          end
        end
      end
    end
  end
end
