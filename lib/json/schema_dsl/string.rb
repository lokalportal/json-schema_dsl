# frozen_string_literal: true

module JSON
  module SchemaDsl
    # String primitive of json schema
    #
    # @see https://json-schema.org/understanding-json-schema/reference/string.html
    class String < Entity
      attribute?(:min_length, Types::Integer)
      attribute?(:max_length, Types::Integer)
      attribute?(:pattern,    Types::String)
      attribute?(:format,     Types::String)
    end
  end
end
