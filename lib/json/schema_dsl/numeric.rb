module JSON
  module SchemaDsl
    class Numeric < Entity
      attribute?(:multiple_of,       Types::Integer)
      attribute?(:minimum,           Types::Integer)
      attribute?(:maximum,           Types::Integer)
      attribute?(:exclusive_minimum, Types::Integer)
      attribute?(:exclusive_maximum, Types::Integer)
    end
  end
end
