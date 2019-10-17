# frozen_string_literal: true

module JSON
  module SchemaDsl
    # Methods for an object to be used as an ast node by the renderer
    # Include this module to define your own types that are not descendants of
    # Entity. You should still implement two methods to be compatible with the
    # normal builder class:
    #
    # #initialize: Hash -> Self
    # #to_h: Self -> Hash
    # .has_attribute?: Symbol -> Boolean
    module AstNode
      def self.included(base)
        base.extend(ClassMethods)
      end

      # @param [Symbol] attribute_name The name of the attribute to update.
      # @param [Object] value The value that will be set for the attribute.
      # @return [Entity] Since entities themselves are immutable, this method returns a new
      #   entity with the attribute_name and value pair added.
      def update(attribute_name, value = nil)
        self.class.new(to_h.merge(attribute_name => value))
      end

      # Used to do a simple render of the entity. Since this has no sensible scope while
      #   rendering, use Builder#render instead.
      # @see JSON::SchemaDsl::Builder#render
      def render
        ::JSON::SchemaDsl::Renderer.new(self).render
      end

      # The class methods that ast nodes should have
      module ClassMethods
        # @return [String] The type that will be used in I.E. `type: 'object'` attributes.
        #   Also used to give names to the dsl and builder methods.
        def infer_type
          type = name.split('::').last.underscore
          type == 'entity' ? nil : type
        end

        # @method! type_method_name
        #   Override this method to set the name of the dsl method for this type.
        alias type_method_name infer_type

        # Override this to set a custom builder for your type.
        # @return [Class] A new builder class for this type.
        def builder
          ::JSON::SchemaDsl::Builder.define_builder(self)
        end
      end
    end
  end
end
