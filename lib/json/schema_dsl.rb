# frozen_string_literal: true

require 'active_support/core_ext/string'
require 'active_support/core_ext/object'
require 'docile'
require 'dry-struct'
require 'dry-types'

require 'json/schema_dsl/version'
require 'json/schema_dsl/types'
require 'json/schema_dsl/entity'

%w[null boolean numeric integer string object array].each do |type|
  require "json/schema_dsl/#{type}"
end

require 'json/schema_dsl/builder'
require 'json/schema_dsl/renderer'
require 'json/schema_dsl/dsl'

module JSON
  module SchemaDsl
    class Error < StandardError; end

    delegate(:type_defaults,
             :reset_type_defaults!,
             :add_defaults_for,
             to: ::JSON::SchemaDsl::Builder)
  end
end
