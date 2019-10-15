# frozen_string_literal: true

module JSON
  module SchemaDsl
    # Number primitive of Json-Schema
    #
    # @see https://json-schema.org/understanding-json-schema/reference/numeric.html#number
    class Numeric < Entity
      attribute?(:multiple_of,       Types::Integer)
      attribute?(:minimum,           Types::Integer)
      attribute?(:maximum,           Types::Integer)
      attribute?(:exclusive_minimum, Types::Integer)
      attribute?(:exclusive_maximum, Types::Integer)
    end

    # Type alias of numeric.
    #
    # @see https://json-schema.org/understanding-json-schema/reference/numeric.html#number
    class Number < Numeric
    end
  end
end
