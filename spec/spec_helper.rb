# frozen_string_literal: true

require 'bundler/setup'
require 'pry'
require 'json/schema_dsl'

module DummyRender
  class Dummy
    include JSON::SchemaDsl

    def self.parse(&block)
      new.object(&block)
    end

    def self.render(&block)
      parse(&block).as_json
    end
  end

  def parsed(&block)
    Dummy.parse(&block)
  end

  def rendered(&block)
    Dummy.render(&block)
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  # config.disable_monkey_patching!

  config.include DummyRender

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
