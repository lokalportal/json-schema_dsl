# frozen_string_literal: true

module JSON
  module SchemaDsl
    class Builder
      class << self
        attr_accessor :inner_class

        def [](klass)
          raise ArgumentError, "#{klass} is not a struct." unless klass < Dry::Struct

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
          if type_defaults[type].empty?
            type_defaults[type] = type_defaults[type].merge(defaults)
          else
            type_defaults[type].merge!(defaults)
          end
        end

        def build(name = nil, scope: nil, **attributes, &block)
          type     = (attributes[:type] || inner_class.infer_type)&.to_sym
          defaults = ::JSON::SchemaDsl::Builder
                     .type_defaults[type].merge(name: name, type: type)
          builder  = new(inner_class.new(defaults), scope: scope)
          Docile.dsl_eval(builder, &config_block(attributes, &block))
        end

        def inspect
          "#<#{class_name} inner_class=#{inner_class}>"
        end

        def class_name
          name || inner_class.name + 'Builder'
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

      attr_reader :inner, :scope
      delegate :as_json, to: :render
      delegate :to_h, to: :inner

      def initialize(inner, scope: nil)
        @inner = inner
        @scope = scope
      end

      def render
        ::JSON::SchemaDsl::Renderer.new(inner, scope).render
      end

      def update(type, *args)
        args = args.first if args.count == 1 && args.is_a?(::Array)
        @inner = if args.is_a?(::Array)
                   inner.update(type, *args)
                 else
                   inner.update(type, args)
                 end
      end

      def build_struct(type, name = nil, **attributes, &block)
        builder = self.class[type || attributes[:type].constantize]
        builder.build(name, **attributes, scope: scope, &block)
      end

      def method_missing(meth, *args, &block)
        return super unless scope&.respond_to?(meth, true)

        maybe_child = scope.send(meth, *args, &block)
        maybe_child.respond_to?(:render) &&
          add_child(maybe_child)
        maybe_child
      end

      def respond_to_missing?(meth, priv)
        return super unless scope

        scope.respond_to?(meth, priv)
      end

      def inspect
        "#<#{self.class.class_name} \n  scope = #{scope}\n  inner = #{inner}> "
      end

      def set(name, *args, **opts, &block)
        args = extract_args(name, args, opts, &block)
        return inner.send(name) unless args

        @inner = update(name, args)
      end

      def extract_args(name, args, opts, &block)
        if block.present? || !inner.class.has_attribute?(name) || opts[:type].present?
          return build_struct(Object, **opts, &block)
        end

        args.presence || opts.presence
      end

      def add_child(child)
        children(children | [child])
        child
      end
    end
  end
end
