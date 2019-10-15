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
      class << self
        # @return [String] The type that will be used in I.E. `type: 'object'` attributes.
        #   Also used to give names to the dsl and builder methods.
        def infer_type
          type = name.split('::').last.underscore
          type == 'entity' ? nil : type
        end

        # @method! type_method_name
        #   Override this method to set the name of the dsl method for this type.
        alias type_method_name infer_type

        # nodoc
        def required_type
          (Types::Bool | Types::Coercible::Array.of(Types::Coercible::String).default { [] })
        end

        # Override this to set a custom builder for your type.
        # @return [Class] A new builder class for this type.
        def builder
          ::JSON::SchemaDsl::Builder.define_builder(self)
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

      delegate :as_json, to: :to_h
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

      # @param [Symbol] attribute_name The name of the attribute to update.
      # @param [Object] value The value that will be set for the attribute.
      # @return [Entity] Since entities themselves are immutable, this method returns a new
      #   entity with the attribute_name and value pair added.
      def update(attribute_name, value = nil)
        self.class.new(to_h.merge(attribute_name => value))
      end

      # Used to do a simple render of the entity. Since this has no sensible scope while
      #   rendering, use Builder#render instead.
      # @see JSON::SchemaDsl::Builder#render
      def render
        ::JSON::SchemaDsl::Renderer.new(self).render
      end
    end
  end
end
