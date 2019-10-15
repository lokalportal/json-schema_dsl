# frozen_string_literal: true

module JSON
  module SchemaDsl
    module Renderers
      # Renderer that translates multiplexer properties (any_of, one_of or all_of)
      # so that a new wrapping structure is returned that holds the original in
      # one of these properties.
      #
      # @example Nullable object
      #   obj = object :james, any_of: [null]
      #   Multiplexer.new(nil).visit(obj)
      #     #=> { type: 'entity', any_of: [{type: 'null'}, {type: 'object', ...}] }
      #
      class Multiplexer < Base
        KEYS = %i[any_of one_of all_of].freeze

        # Boxes the entity into a new one with the multiplexer attribute set
        # to the entity, if required.
        def visit(entity)
          traverse(box(entity))
        end

        private

        # Boxes the given entity unless it is of type 'entity' or has no
        # multiplexer attributes. The entity itself will be added to the "box"
        # if it has any other attributes set by the user.
        # @param [Hash] entity The entity that may have a multiplexer attribute.
        def box(entity)
          present_key = entity[:type] != 'entity' && KEYS.find { |k| entity[k].present? }
          return entity unless present_key

          new_value = entity[present_key].map { |ch| visit(ch) }
          unless container?(entity.except(present_key))
            new_value.push(entity.except(present_key))
          end

          { type: 'entity', present_key => new_value.reject(&:blank?) }
        end

        # @return [Boolean] `true` if the object is only there to have the
        #   boxing attribute, false otherwise.
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
