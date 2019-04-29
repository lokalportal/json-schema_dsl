module JSON
  module SchemaDsl
    module Monads
      class Base
        class << self
          attr_accessor :identifier_key
        end

        attr_reader :inner

        def initialize(inner)
          @inner = inner
          @applicable = inner[self.class.identifier_key].present?
        end

        def fmap
          @inner = yield @inner
          self
        end

        def as_json
          @applicable ? monad_json : @inner.as_json
        end

        def monad_json
          key = self.class.identifier_key.to_s.camelize(:lower)
          { key => inner[key].map { |ch| Renderer.render(ch) } }.as_json
        end
      end

      class None < Base
        def as_json
          @inner.as_json
        end
      end

      class AnyOf < Base
        self.identifier_key = :any_of
      end

      class OneOf < Base
        self.identifier_key = :one_of
      end

      class AllOf < Base
        self.identifier_key = :all_of
      end
    end
  end
end
