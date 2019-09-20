# frozen_string_literal: true

module JSON
  module SchemaDsl
    JSON::SchemaDsl::Entity.descendants.push(JSON::SchemaDsl::Entity).each do |type|
      builder = JSON::SchemaDsl::Builder[type]
      type_param = type.infer_type || 'entity'
      define_method(type_param) do |name = nil, **attributes, &block|
        builder.build(name, attributes, &block)
      end
    end
  end
end
