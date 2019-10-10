# frozen_string_literal: true

module JSON
  module SchemaDsl
    class Entity < Dry::Struct
      class << self
        def infer_type
          type = name.split('::').last.underscore
          type == 'entity' ? nil : type
        end
        alias type_method_name infer_type

        def self_type
          Types.Constructor(self)
        end

        def required_type
          (Types::Bool | Types::Coercible::Array.of(Types::Coercible::String).default { [] })
        end

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

      def to_h
        super.transform_values do |v|
          is_array = v.respond_to?(:each)
          if (is_array ? v.first : v).respond_to?(:to_h)
            is_array ? v.map(&:to_h) : v.to_h
          else
            v
          end
        end
      end

      def update(attribute_name, value = nil)
        self.class.new(to_h.merge(attribute_name => value))
      end

      def render
        ::JSON::SchemaDsl::Renderer.new(self).render
      end

      def as_json
        render.as_json
      end
    end
  end
end
