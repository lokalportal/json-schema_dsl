# frozen_string_literal: true

module JSON
  module SchemaDsl
    # Builders are used to build entity-structs. They handle building this raw data so
    # it can then be given to the renderers which modify the structure to be valid json-schema.
    #
    # Each type has an associated Builder that is a dynamically generated class.
    # Since entity-structs are immutable, the builder updates the struct and keeps track of the
    # latest version of the struct.
    #
    # Entity definitions can mostly be treated as data input while most of the logic of building
    # the entity tree resides in the builders.
    # @todo Refactor class and remove rubocop exception
    # rubocop:disable Metrics/ClassLength
    class Builder
      class << self
        attr_accessor :inner_class

        # @param [Class] klass A class that is a subclass of {JSON::SchemaDsl::Entity}.
        # @return A new builder class that subclasses {JSON::SchemaDsl::Builder}
        def [](klass)
          raise ArgumentError, "#{klass} is not a struct." unless klass < AstNode

          registered_builders[klass] ||= klass.builder
        end

        # @return [Array<JSON::SchemaDsl::Builder>] All builders that have been
        #   registered so far. Usually builders get automatically registered when
        #   the associated type is registered.
        def registered_builders
          @registered_builders ||= {}
        end

        # @return [Hash<Symbol, Hash>] Defaults that are applied when a new struct of a
        #   given type is contsructed. The type symbol is the key and the defaults the value
        #   of this hash.
        def type_defaults
          @type_defaults ||= Hash.new { {} }
        end

        # Clears the registered type defaults and returns an empty hash.
        # @return [Hash<Symbol, Hash>]
        # @see #type_defaults
        def reset_type_defaults!
          type_defaults.clear
        end

        # Adds new defaults for the given type.
        # @param [Symbol] type The type symbol for the type. Usually the name underscored and
        #   symbolized. I.e. {JSON::SchemaDsl::Object} => `:object`.
        # @param [Hash<Symbol, Object>] defaults New defaults that will be merged to
        #   the existing ones.
        # @return [Hash<Symbol, Hash>]
        # @see #type_defaults
        def add_defaults_for(type, defaults)
          if type_defaults[type].empty?
            type_defaults[type] = type_defaults[type].merge(defaults)
          else
            type_defaults[type].merge!(defaults)
          end
        end

        # Instantiates a new builder instance with a corresponding entity and
        # applies the attributes and block to construct a complete entity.
        # @param [#to_s] name The name of the new entity. This is important for the entity
        #   to be added to properties later. Usually is the name of a property or the pattern
        #   for a pattern property.
        # @param [Object] scope The scope will be used as a fallback to evaluate the block.
        #   If there are any methods that the block does not understand, the scope will
        #   be called instead.
        # @param [Hash] attributes The initial attributes that the entity will start with
        #   before the block is applied.
        # @param [Proc] block Will be evaluated in the context of the builder. Should contain
        #  setter methods.
        #
        def build(name = nil, scope: nil, **attributes, &block)
          type     = (attributes[:type] || inner_class.infer_type)&.to_sym
          defaults = ::JSON::SchemaDsl::Builder
                     .type_defaults[type].merge(name: name, type: type)
          builder  = new(inner_class.new(defaults), scope: scope)
          Docile.dsl_eval(builder, &config_block(attributes, &block))
        end

        # nodoc
        def inspect
          "#<#{class_name} inner_class=#{inner_class}>"
        end

        # nodoc
        def class_name
          name || inner_class.name + 'Builder'
        end

        # Defines a new method for the builder instance that mirrors the dsl method
        #   for the given type.
        # @param [Class] type A class that is a subclass of {JSON::SchemaDsl::Entity}.
        def define_builder_method(type)
          type_param = type.type_method_name || 'entity'
          define_method(type_param) do |name = nil, **attributes, &block|
            new_child = build_struct(type, name, **attributes, &block)
            add_child(new_child)
          end
        end

        # @param [Class] klass A class that is a subclass of {JSON::SchemaDsl::Entity}.
        # @return A new builder class that subclasses {JSON::SchemaDsl::Builder}
        # @see #[]
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

        # Combines a set of attributes and a block into a single proc.
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

      # @param [JSON::SchemaDsl::Entity] inner The struct that the builder is supposed
      #   to update and build up.
      # @param [Object] scope The scope is used for as a fallback for helper methods.
      # @see JSON::SchemaDsl::Builder.build
      def initialize(inner, scope: nil)
        @inner = inner
        @scope = scope
      end

      # Renders the given tree structure into a hash. Note that this hash still has symbol keys.
      #   The scope used for the render is the same as the builder.
      # @see JSON::SchemaDsl::Renderer#render
      def render
        ::JSON::SchemaDsl::Renderer.new(inner, scope).render
      end

      private

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
    # rubocop:enable Metrics/ClassLength
  end
end
