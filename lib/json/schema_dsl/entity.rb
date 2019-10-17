# frozen_string_literal: true

module JSON
  module SchemaDsl
    # The basic entity type for json schemas.
    #
    # This is mostly used in cases where you don't exactly know what type a property will have,
    # for example if the property is an `anyOf` of different types.
    #
    # Internally it is used as the superclass of all other types.
    class Entity < Dry::Struct
      include AstNode

      class << self
        # nodoc
        def required_type
          (Types::Bool | Types::Coercible::Array.of(Types::Coercible::String).default { [] })
        end
      end

      attribute(:enum,     Types::Coercible::Array.default { [] })
      attribute(:all_of,   Types::Coercible::Array.default { [] })
      attribute(:any_of,   Types::Coercible::Array.default { [] })
      attribute(:one_of,   Types::Coercible::Array.default { [] })
      attribute(:children, Types::Coercible::Array.default { [] })
      attribute?(:nullable,    Types::Bool.default(false))
      attribute?(:name,        (Types.Instance(Regexp) | Types::Coercible::String))
      attribute?(:type,        Types::Coercible::String)
      attribute?(:title,       Types::Coercible::String)
      attribute?(:description, Types::Coercible::String)
      attribute?(:default,     Types::Coercible::String)
      attribute?(:required,    required_type)
      attribute?(:not_a,       Types::String)
      attribute?(:ref,         Types::String)
      attribute?(:definitions, Types::String)

      # @return [Hash<Symbol, Object>] Returns this entity as a hash and all children and
      #   properties as simple values. This structure is used to render the eventual
      #   schema by the renderer.
      # @see JSON::SchemaDsl::Rederer#initialize
      def to_h
        super.transform_values do |v|
          is_array = v.is_a?(::Array)
          if (is_array ? v.first : v).respond_to?(:to_h)
            is_array ? v.map(&:to_h) : v.to_h
          else
            v
          end
        end
      end
      delegate :as_json, to: :to_h
    end
  end
end
