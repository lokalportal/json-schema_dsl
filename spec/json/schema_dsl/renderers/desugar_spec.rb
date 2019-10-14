# frozen_string_literal: true

describe JSON::SchemaDsl::Renderers::Desugar do
  describe '.visit' do
    subject { described_class.new(nil).visit(input) }

    context 'it desugars nullable' do
      let(:input) { { type: :string, nullable: true } }

      it { is_expected.to include(any_of: [{ type: 'null' }]) }
      it { is_expected.to include(nullable: nil) }
      it { is_expected.to include(type: :string) }
      it { is_expected.to include(type: :string, any_of: [{ type: 'null' }]) }

      context 'even if there are already any_of options' do
        let(:input) { { nullable: true, any_of: [{ type: 'string' }] } }
        let(:any_of) { [{ type: 'string' }, { type: 'null' }] }

        it { is_expected.to include(any_of: any_of) }
      end
    end

    context 'it desugars children' do
      let(:children) { [{ name: 'jeff', type: 'string' }, { name: 'john', type: 'number' }] }
      let(:input)    { { type: 'object', children: children } }

      it 'moves the children to the properties and associates by name' do
        expect(subject[:properties].keys).to eq(%w[jeff john])
        expect(subject[:properties].values).to eq(children)
      end

      it 'removes the children' do
        expect(subject[:children]).to be_nil
      end

      context 'in a nested structure' do
        let(:input) { { type: 'array', items: [super()] } }

        it 'traverses that structure' do
          expect(subject[:items].first.keys).to include(:properties)
        end
      end

      context 'when there are names that are regexps' do
        let(:pattern_child) { { name: /^tlc/, type: 'string' } }
        let(:children)      { super() << pattern_child }

        it 'moves them to the pattern properties' do
          expect(subject[:properties].values).not_to     include(pattern_child)
          expect(subject[:pattern_properties].keys).to   include(pattern_child[:name])
          expect(subject[:pattern_properties].values).to include(pattern_child)
        end
      end

      context 'when a child is required' do
        let(:required_child) { { name: 'Id', type: 'number', required: true } }
        let(:children)       { super() << required_child }

        it 'adds the name to the required array' do
          expect(subject[:required]).to include(required_child[:name])
        end

        it 'removes the required tag from the child' do
          expect(subject[:properties].values.last).to include(required: nil)
        end

        context 'and there are already required properties' do
          let(:input) { super().merge(required: ['Jeff']) }

          it 'still adds the name to the required array' do
            expect(subject[:required]).to include(required_child[:name])
          end

          context 'and the property is already mentioned there' do
            let(:input) { super().merge(required: [required_child[:name]]) }

            it 'still adds the name to the required array' do
              expect(subject[:required]).to eq(%w[Id])
            end
          end
        end
      end
    end
  end
end
