# frozen_string_literal: true

module JSON
  module SchemaDsl
    # Custom namespace for dry-types.
    #
    # @see https://dry-rb.org/gems/dry-types/1.0/
    class Types
      include Dry.Types()
    end
  end
end
