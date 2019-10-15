# frozen_string_literal: true

module JSON
  module SchemaDsl
    # Type that validates a json entity to be an array.
    #
    # @see https://json-schema.org/understanding-json-schema/reference/array.html
    class Array < Entity
      attribute?(:unique_items, Types::Bool)
      attribute?(:additional_items, Types::Bool)
      attribute?(:min_items, Types::Bool)
      attribute?(:max_items, Types::Bool)
      attribute?(:items, Types::Any)
    end
  end
end
