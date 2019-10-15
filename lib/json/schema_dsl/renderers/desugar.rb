# frozen_string_literal: true

module JSON
  module SchemaDsl
    module Renderers
      # By default the first renderer that visits the tree.
      # This renderer will translate all kinds of `syntax sugar` to
      # a uniform format that fits json-schema.
      class Desugar < Base
        # Desugars all syntax sugar in that entity. This resolves concepts
        # like `children` and `nullable` that are not present in the json
        # schema specification itself but are used by the builder to ease
        # the writing of schemas. In turn it
        #
        # * Transforms children to properties
        # * Translates the `:required` attribute to the parent if true.
        # * Collapses the item attribute of arrays into a single entity.
        def visit(entity)
          traverse(expand_children(nullable(entity)))
        end

        private

        def expand_children(entity)
          return entity unless entity[:children]
          return collapse_items(entity) if entity[:items]

          entity
            .merge(required_properties(entity))
            .merge(properties_properties(entity))
        end

        # Collapses the items into the first child for arrays.
        def collapse_items(entity)
          items = entity[:items]
          items = items[:children].first if items[:children].to_a.count == 1
          entity.merge(items: items)
        end

        # @param [Hash] entity An object entity-hash that has children.
        # @return [Hash] The hash with children translated into properties and
        # @todo Enable and fix rubocop warning about AbcSize
        # rubocop:disable Metrics/AbcSize
        def properties_properties(entity)
          entity[:children]
            .filter { |ch| ch[:name].present? }
            .map { |ch| ch[:name] }
            .zip(entity[:children].map { |c| visit(c) })
            .map(&unrequire_property)
            .group_by { |(name, _obj)| name.class }
            .transform_keys { |k| k == Regexp ? :pattern_properties : :properties }
            .transform_values(&:to_h)
            .merge(children: nil)
        end
        # rubocop:enable Metrics/AbcSize

        def unrequire_property
          lambda do |(name, obj)|
            obj = obj[:required] == true ? obj.merge(required: nil) : obj
            [name, obj]
          end
        end

        # Translates the required-properties of children into the required array
        # of the parent structure.
        def required_properties(entity)
          requireds = entity[:children]
                      .select { |ch| ch[:required] == true }
                      .map { |ch| ch[:name].to_s }
          pre_req = entity[:required].is_a?(Array) ? entity[:required] : []
          { required: requireds | pre_req }
        end

        # Translates nullable property into a any_of: [null...]
        def nullable(entity)
          return entity unless entity[:nullable]

          entity.merge(nullable: nil, any_of: [{ type: 'null' }]) do |k, old, new|
            next unless k == :any_of

            old + new
          end
        end
      end
    end
  end
end
