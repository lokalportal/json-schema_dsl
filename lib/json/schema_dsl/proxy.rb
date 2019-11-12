# frozen_string_literal: true

module JSON
  module SchemaDsl
    # A small proxy for the dsl that enables a nicer api for building schemas on the fly
    class Proxy
      include ::JSON::SchemaDsl
    end
  end
end
