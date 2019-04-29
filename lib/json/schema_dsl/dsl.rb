module JSON
  module SchemaDsl
    JSON::SchemaDsl::Entity.descendants.each do |type|
      builder = JSON::SchemaDsl::Builder[type]
      type_param = type.infer_type
      define_method(type_param) do |name = nil, **attributes, &block|
        builder.build(name, attributes, &block)
      end
    end
  end
end
