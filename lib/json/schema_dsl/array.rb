# frozen_string_literal: true

module JSON
  module SchemaDsl
    class Array < Entity
      attribute?(:unique_items, Types::Bool)
      attribute?(:additional_items, Types::Bool)
      attribute?(:min_items, Types::Bool)
      attribute?(:max_items, Types::Bool)
      attribute?(:items, Types::Any)
    end
  end
end
