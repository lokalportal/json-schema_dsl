# frozen_string_literal: true

describe JSON::SchemaDsl::Renderers::Alias do
  describe '.visit' do
    subject { described_class.visit(input) }

    context 'with a ref' do
      let(:input) { { ref: 2 } }

      it 'applies the registered aliases' do
        is_expected.to include("$ref": 2)
      end
    end

    context 'with snake_cased keys' do
      let(:input) { { pattern_properties: ['^james'] } }

      it 'turn keys to camelcase' do
        is_expected.to include(patternProperties: ['^james'])
      end

      context 'that are nested' do
        context 'in a Hash' do
          let(:input) { { properties: { data: { created_at: { type: 'string' } } } } }

          it 'does camelize the key' do
            expect(subject.dig(:properties, :data, :createdAt)).to eq(type: 'string')
          end
        end

        context 'in an Array' do
          let(:input) { { items: [{ pattern_properties: ['^james'] }] } }

          it 'does camelize the key' do
            expect(subject[:items].first).to include(patternProperties: ['^james'])
          end
        end
      end

      context 'that are names' do
        let(:input) { { properties: { a_name: { type: 'null' } } } }

        it 'does not downcase the name' do
          expect(subject.dig(:properties, :a_name)).to eq(type: 'null')
        end
      end
    end
  end
end
