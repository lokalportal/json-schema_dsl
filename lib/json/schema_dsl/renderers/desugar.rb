# frozen_string_literal: true

module JSON
  module SchemaDsl
    module Renderers
      class Desugar < Base
        class << self
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

          def collapse_items(entity)
            items = entity[:items]
            items = items[:children].first if items[:children].to_a.count == 1
            entity.merge(items: items)
          end

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

          def unrequire_property
            lambda do |(name, obj)|
              obj = obj[:required] == true ? obj.merge(required: nil) : obj
              [name, obj]
            end
          end

          def required_properties(entity)
            requireds = entity[:children]
                        .select { |ch| ch[:required] == true }
                        .map { |ch| ch[:name].to_s }
            pre_req = entity[:required].is_a?(Array) ? entity[:required] : []
            { required: requireds | pre_req }
          end

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
end
