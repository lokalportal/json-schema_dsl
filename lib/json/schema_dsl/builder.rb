# frozen_string_literal: true

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
          builder  = new(inner_class.new(defaults))
          Docile.dsl_eval(builder, &config_block(attributes, &block))
        end

        def inspect
          "#<#{name} inner_class=#{inner_class}>"
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

            klass.schema.keys.each do |key|
              name = key.name
              define_method(name) do |*args, **opts, &block|
                return inner.send(name) if args.empty? && opts.empty? && block.nil?

                args = build_struct(Object, **opts, &block) if opts.present? || !block.nil?
                @inner = update(name, args)
              end
            end
          end
          Class.new(self, &definition)
        end
      end

      attr_reader :inner
      delegate :as_json, :to_h, :render, to: :inner

      def initialize(inner)
        @inner = inner
      end

      def update(type, *args)
        args = args.first if args.count == 1
        @inner = inner.update(type, *args)
      end

      def build_struct(type, name = nil, **attributes, &block)
        builder = self.class[type || attributes[:type].constantize]
        builder.build(name, **attributes, &block)
      end

      JSON::SchemaDsl::Entity.descendants.push(JSON::SchemaDsl::Entity).each do |type|
        type_param = type.infer_type || 'entity'
        define_method(type_param) do |name = nil, **attributes, &block|
          new_child = build_struct(type, name, **attributes, &block)
          children(children | [new_child])
          new_child
        end
      end
    end
  end
end
