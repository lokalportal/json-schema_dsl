# frozen_string_literal: true

describe JSON::SchemaDsl::Renderers::Alias do
  describe '.visit' do
    subject(:aliased) { described_class.new(nil).visit(input) }

    context 'with a ref' do
      let(:input) { { ref: 2 } }

      it 'applies the registered aliases' do
        expect(aliased).to include("$ref": 2)
      end
    end

    context 'with snake_cased keys' do
      let(:input) { { pattern_properties: ['^james'] } }

      it 'turn keys to camelcase' do
        expect(aliased).to include(patternProperties: ['^james'])
      end

      context 'when nested' do
        context 'when in a Hash' do
          let(:input) { { properties: { data: { created_at: { type: 'string' } } } } }

          it 'does camelize the key' do
            expect(aliased.dig(:properties, :data, :createdAt)).to eq(type: 'string')
          end
        end

        context 'when in an Array' do
          let(:input) { { items: [{ pattern_properties: ['^james'] }] } }

          it 'does camelize the key' do
            expect(aliased[:items].first).to include(patternProperties: ['^james'])
          end
        end
      end

      context 'when that are names' do
        let(:input) { { properties: { a_name: { type: 'null' } } } }

        it 'does not downcase the name' do
          expect(aliased.dig(:properties, :a_name)).to eq(type: 'null')
        end
      end
    end
  end
end
