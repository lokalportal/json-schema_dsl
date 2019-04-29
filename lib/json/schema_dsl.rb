require 'active_support/core_ext/string'
require 'active_support/core_ext/object'
require 'docile'
require 'dry-struct'
require 'dry-types'

require 'json/schema_dsl/version'
require 'json/schema_dsl/types'
require 'json/schema_dsl/entity'
require 'json/schema_dsl/monads'

%w[null numeric integer string object monads].each do |type|
  require "json/schema_dsl/#{type}"
end

require 'json/schema_dsl/builder'
require 'json/schema_dsl/renderer'
require 'json/schema_dsl/dsl'

module JSON
  module SchemaDsl
    class Error < StandardError; end
    # Your code goes here...
  end
end
