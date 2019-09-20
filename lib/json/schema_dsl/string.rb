# frozen_string_literal: true

module JSON
  module SchemaDsl
    class String < Entity
      attribute?(:min_length, Types::Integer)
      attribute?(:max_length, Types::Integer)
      attribute?(:pattern,    Types::String)
      attribute?(:format,     Types::String)
    end
  end
end
