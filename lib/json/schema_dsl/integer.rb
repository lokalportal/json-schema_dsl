# frozen_string_literal: true

module JSON
  module SchemaDsl
    # The primitive integer type for json schema.
    #
    # @see https://json-schema.org/understanding-json-schema/reference/numeric.html
    class Integer < Entity
      attribute?(:multiple_of,       Types::Integer)
      attribute?(:minimum,           Types::Integer)
      attribute?(:maximum,           Types::Integer)
      attribute?(:exclusive_minimum, Types::Integer)
      attribute?(:exclusive_maximum, Types::Integer)
    end
  end
end
