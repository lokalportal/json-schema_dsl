# Json::SchemaDsl

`JSON::SchemaDsl` is a gem that gives you the ability to simply and comfortably
define json-schemas in ruby. It will type-check and coerce the attributes of
your definitions and gives you an easy to extend and performant way to generate
schemas.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'json-schema_dsl'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install json-schema_dsl

## Usage

To use the gem include the main module into a class of yours:

```rb
class Builder
  include JSON::SchemaDsl
end
```

Now that class has the ability to define new schemas for you.

```rb
Builder.new.object do
  object :meta do
    string :response_code
    integer :returned_count
  end

  array :data do
    items do
      object do
        string :name, required: true
        integer :id, minimum: 0
      end
    end
  end
end.as_json
```

Will generate

```js
{
  type: object,
  properties: {
    meta: {
      type: object,
      properties: {
        response_code: {
          type: string
        },
        returned_count: {
          type: integer
        }
      }
    },
    data: {
      type: array,
      items: {
        type: object,
        required: [
          name
        ],
        properties: {
          name: {
            type: string
          },
          id: {
            type: integer,
            minimum: 0
          }
        }
      }
    }
  }
}
```

### Helper methods

You can define helper methods on your builder to dry up your definitions.
```rb
class Builder
  include JSON::SchemaDsl

  def book
    object do
      string :author
      string :title
    end
  end
end

Builder.new.array do
  items { book }
end
```
Note that to attach the object to the definition that calls the helper method,
it has to return a `JSON::Schema::Entity`. If the return value is used to
construct another entity, this is not necessary.
```js
{
  type: array,
  items: {
    type: object,
    properties: {
      author: {
        type: string
      },
      title: {
        type: string
      }
    }
  }
}
```

### Defaults

In an initializer, you can change default values for certain types of entities:
```rb
# Adding new defaults for object
JSON::SchemaDsl.add_defaults_for(:object, {additional_properties: false})

Builder.new.object
```
This will give the object the property `additionalProperties` with the value
`false`.
```js
{
  type: object,
  additionalProperties: false
}
```

## Extending the gem

You an add additional types and renderers to the gem by registering them:
```rb
# For now, types have to subclass Entity
# For this example we can define an email type
class Email < JSON::SchemaDsl::String
  def self.type_method_name
    'email'
  end

  def self.infer_type
    'string'
  end

  attribute(:format, JSON::SchemaDsl::Types::String.default('e-mail'))
end
JSON::SchemaDsl.register_type(Email)
```
Now you can use email in all your builders using the method name:
```rb
Builder.new.object do
  email :address
end
```
Will generate
```js
{
  type: object,
  properties: {
    address: {
      type: string,
      format: e-mail
    }
  }
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/json-schema_dsl. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Json::SchemaDsl project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/json-schema_dsl/blob/master/CODE_OF_CONDUCT.md).
