module JSON
  module SchemaDsl
    class Builder
      class << self
        attr_accessor :inner_class

        def [](klass)
          registered_builders[klass] ||= define_builder(klass)
        end

        def registered_builders
          @registered_builders ||= {}
        end

        def build(name = nil, **attributes, &block)
          defaults = { name: name, type: inner_class.infer_type }
          builder = new(inner_class.new(defaults))
          Docile.dsl_eval(builder, &config_block(attributes, &block))
        end

        def inspect
          "#<JSON::SchemaDsl::Builder inner_class=#{inner_class}>"
        end

        private

        def config_block(attributes, &block)
          proc do
            attributes.each { |k, v| send(k, v) }
            instance_eval(&block) if block_given?
          end
        end

        def define_builder(klass)
          definition = proc do
            self.inner_class = klass

            klass.schema.keys.map(&:name).each do |name|
              define_method(name) do |*args|
                return inner.send(name) if args.empty?

                @inner = update(name, args)
              end
            end
          end
          Class.new(self, &definition)
        end
      end

      attr_reader :inner

      def initialize(inner)
        @inner = inner
      end

      def render
        inner.render
      end

      def update(type, *args)
        args = args.first if args.count == 1
        @inner = inner.update(type, *args)
      end

      JSON::SchemaDsl::Entity.descendants.each do |type|
        builder = self[type]
        type_param = type.infer_type.downcase
        define_method(type_param) do |name = nil, **attributes, &block|
          new_child = builder.build(name, **attributes, &block).inner
          children(children | [new_child])
          new_child
        end
      end
    end
  end
end
