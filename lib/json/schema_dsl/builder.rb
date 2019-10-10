# frozen_string_literal: true

module JSON
  module SchemaDsl
    class Builder
      class << self
        attr_accessor :inner_class

        def [](klass)
          registered_builders[klass] ||= klass.builder
        end

        def registered_builders
          @registered_builders ||= {}
        end

        def type_defaults
          @type_defaults ||= Hash.new { {} }
        end

        def reset_type_defaults!
          type_defaults.clear
        end

        def add_defaults_for(type, defaults)
          type_defaults[type].merge!(defaults)
        end

        def build(name = nil, scope: nil, **attributes, &block)
          type     = (attributes[:type] || inner_class.infer_type)&.to_sym
          defaults = ::JSON::SchemaDsl::Builder
                     .type_defaults[type].merge(name: name, type: type)
          builder  = new(inner_class.new(defaults), scope: scope)
          Docile.dsl_eval(builder, &config_block(attributes, &block))
        end

        def inspect
          "#<#{name || inner_class.name + 'Builder'} inner_class=#{inner_class}>"
        end

        def define_builder_method(type)
          type_param = type.type_method_name || 'entity'
          define_method(type_param) do |name = nil, **attributes, &block|
            new_child = build_struct(type, name, **attributes, &block)
            add_child(new_child)
          end
        end

        def define_builder(klass)
          Class.new(self) do
            self.inner_class = klass
            klass.schema.keys.map(&:name).each do |name|
              define_method(name) do |*args, **opts, &block|
                set(name, *args, **opts, &block)
              end
            end
          end
        end

        private

        def config_block(attributes, &block)
          proc do
            attributes.each { |k, v| send(k, v) }
            instance_exec(&block) if block_given?
          end
        end
      end

      attr_reader :inner
      delegate :as_json, :to_h, :render, to: :inner

      def initialize(inner, scope: nil)
        @inner = inner
        @scope = scope
      end

      def update(type, *args)
        args = args.first if args.count == 1
        @inner = inner.update(type, *args)
      end

      def build_struct(type, name = nil, **attributes, &block)
        builder = self.class[type || attributes[:type].constantize]
        builder.build(name, **attributes, scope: @scope, &block)
      end

      def method_missing(meth, *args, &block)
        return super unless @scope&.respond_to?(meth, true)

        maybe_child = @scope.send(meth, *args, &block)
        maybe_child.is_a?(::JSON::SchemaDsl::Builder) &&
          add_child(maybe_child)
        maybe_child
      end

      def respond_to_missing?(meth, priv)
        return super unless @scope

        @scope.respond_to?(meth, priv)
      end

      def set(name, *args, **opts, &block)
        return inner.send(name) if args.empty? && opts.empty? && block.nil?

        args = build_struct(Object, **opts, &block) if opts.present? || !block.nil?
        @inner = update(name, args)
      end

      def add_child(child)
        children(children | [child])
        child
      end
    end
  end
end
