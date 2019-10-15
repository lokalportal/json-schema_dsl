# frozen_string_literal: true

module JSON
  module SchemaDsl
    # Object type of JSON-Schema
    #
    # @see https://json-schema.org/understanding-json-schema/reference/object.html
    class Object < Entity
      attribute(:pattern_properties, Types::Array.of(Types.Instance(Regexp)).default { [] })
      attribute?(:min_properties, Types::Integer)
      attribute?(:max_properties, Types::Integer)
      attribute?(:additional_properties, Types::Bool)
    end
  end
end
