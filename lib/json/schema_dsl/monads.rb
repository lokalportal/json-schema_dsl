module JSON
  module SchemaDsl
    module Monads
      class Base
        class << self
          attr_accessor :identifier_key
        end

        def initialize(inner)
          @inner = inner
          @applicable = dig_inner[self.class.identifier_key].present?
        end

        def dig_inner
          if @inner.is_a?(::JSON::SchemaDsl::Monads::Base)
            @inner.dig_inner
          else
            @inner
          end
        end

        def fmap(&block)
          @inner = if @inner.is_a?(Base)
                     @inner.fmap(&block)
                   else
                     yield @inner
                   end
          self
        end

        def as_json
          if @applicable
            monad_json
          else
            @inner.as_json
          end
        end

        def monad_json
          key = self.class.identifier_key.to_s.camelize(:lower)
          { key => dig_inner[key].map { |ch| Renderer.render(ch) } }.as_json
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
