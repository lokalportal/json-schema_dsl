module JSON
  module SchemaDsl
    class Object < Entity
      attribute(:pattern_properties, Types::Array.of(Types.Instance(Regexp)).default { [] })
      attribute?(:min_properties, Types::Integer)
      attribute?(:max_properties, Types::Integer)
      attribute?(:additional_properties, Types::Bool)
    end
  end
end
