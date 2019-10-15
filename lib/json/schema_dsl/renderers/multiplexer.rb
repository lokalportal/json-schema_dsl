# frozen_string_literal: true

module JSON
  module SchemaDsl
    module Renderers
      class Multiplexer < Base
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
          cleaned_up = clean_up(entity)

          cleaned_up[:type].to_s == 'object' && cleaned_up.keys.count <= 1
        end

        def clean_up(entity)
          defaults = ::JSON::SchemaDsl.type_defaults[entity[:type].to_sym]
          (entity.to_a - defaults.to_a).to_h.yield_self do |without_defaults|
            Renderers::Filter.new(scope).visit(without_defaults)
          end
        end
      end
    end
  end
end
