# frozen_string_literal: true

describe JSON::SchemaDsl do
  include described_class
  after { described_class.reset_schema_dsl! }

  describe '#register_type' do
    let!(:email_type) do
      Class.new(JSON::SchemaDsl::String) do
        def self.type_method_name
          'email'
        end

        def self.infer_type
          'string'
        end

        attribute(:format, JSON::SchemaDsl::Types::String.default('e-mail'))
      end
    end

    shared_context('when type registered') do
      before { described_class.register_type(email_type) }
    end

    context 'when the type has not been registered' do
      subject { described_class.instance_methods }

      it { is_expected.not_to include(:email) }
    end

    context 'when the type has been registered' do
      include_context 'when type registered'

      it 'defines the type method' do
        expect(described_class.instance_methods).to include(:email)
      end

      it 'is added to registered types' do
        expect(described_class.registered_types).to include(email_type)
      end

      it 'can be undefined using reset' do
        described_class.reset_schema_dsl!
        expect(described_class.instance_methods).not_to include(:email)
      end
    end

    context 'when the new type is used in a schema' do
      include_context 'when type registered'

      let(:schema) do
        object do
          email :email_address
        end
      end

      it 'inherits the extended type' do
        expect(schema.as_json.dig('properties', 'email_address'))
          .to eq({ type: 'string', format: 'e-mail' }.as_json)
      end
    end
  end
end
