module JSON
  module SchemaDsl
    class Entity < Dry::Struct
      class << self
        def infer_type
          type = name.split('::').last.underscore
          type == 'entity' ? nil : type
        end

        def self_type
          Types.Constructor(self)
        end

        def required_type
          (Types::Bool | Types::Coercible::Array.of(Types::Coercible::String).default { [] })
        end
      end

      attribute(:enum,     Types::Coercible::Array.default { [] })
      attribute(:all_of,   Types::Coercible::Array.default { [] })
      attribute(:any_of,   Types::Coercible::Array.default { [] })
      attribute(:one_of,   Types::Coercible::Array.default { [] })
      attribute(:children, Types::Coercible::Array.default { [] })
      attribute(:nullable, Types::Bool.default(false))
      attribute?(:name,        (Types.Instance(Regexp) | Types::Coercible::String))
      attribute?(:type,        Types::Coercible::String)
      attribute?(:title,       Types::Coercible::String)
      attribute?(:description, Types::Coercible::String)
      attribute?(:default,     Types::Coercible::String)
      attribute?(:required,    required_type)
      attribute?(:not_a,       Types::String)
      attribute?(:ref,         Types::String)
      attribute?(:definitions, Types::String)

      def infer_type!
        update(type: self.class.infer_type)
      end

      def update(attribute_name, value)
        self.class.new(to_h.merge(attribute_name => value))
      end

      def render
        ::JSON::SchemaDsl::Renderer.new(self).render
      end
    end
  end
end
