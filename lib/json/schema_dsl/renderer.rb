module JSON
  module SchemaDsl
    class Renderer
      ALIASES = {
        'ref' => '$ref'
      }.freeze

      INVISIBLES = %w[children nullable name].freeze
      attr_reader :entity

      def initialize(entity)
        @entity = entity.to_h
      end

      def self.render(entity)
        new(entity).render
      end

      def render
        entity
          .yield_self { |h| collection_monad(h) }
          .fmap { |inner| inner.merge(replacement_attributes) }
          .fmap { |inner| apply_key_transformations(inner) }
          .fmap { |inner| apply_filters(inner) }
          .as_json
      end

      private

      def presence_of(obj, preserve: [])
        return obj if preserve.include? obj

        obj.presence
      end

      def apply_key_transformations(hash)
        hash
          .transform_keys { |key| key.to_s.camelize(:lower) }
          .transform_keys { |key| ALIASES[key] || key }
      end

      def apply_filters(hash)
        hash
          .except(*INVISIBLES)
          .transform_values { |v| presence_of(v, preserve: [false]) }
          .compact
      end

      # @param [Hash] hash The input hash used as the inner value
      # @return [Monad::Base] The monad that wraps the inner value to maybe render the inner
      #   value in a wrapping hash.
      def collection_monad(hash)
        [Monads::AnyOf, Monads::AllOf, Monads::OneOf]
          .inject(Monads::None.new(hash)) do |monad, klass|
          hash[klass.identifier_key].present? ? klass.new(hash) : monad
        end
      end

      def replacement_attributes
        nullable_attributes
          .merge(required_attributes)
          .merge(properties_attributes)
      end

      def nullable_attributes
        return {} unless entity[:nullable]

        {
          nullable: nil,
          any_of: entity[:any_of] + [Null.new.infer_type!]
        }
      end

      def properties_attributes
        return {} unless entity[:type] == 'object'

        entity[:children]
          .map { |ch| ch[:name] }
          .zip(entity[:children].map { |c| self.class.render(c) })
          .group_by { |(name, _obj)| name.class }
          .transform_keys { |k| k == Regexp ? :pattern_properties : :properties }
          .transform_values(&:to_h)
      end

      def required_attributes
        {
          required: entity[:children]
            .select { |ch| ch[:required] == true }
            .map { |ch| ch[:name] }.compact
        }
      end
    end
  end
end
