# frozen_string_literal: true

describe JSON::SchemaDsl::Renderers::Multiplexer do
  describe '.visit' do
    subject(:boxed) { described_class.new(nil).visit(input) }

    context 'when there is no multiplexer keyword' do
      let(:input) { { type: :string } }

      it { is_expected.to eq(type: :string) }
    end

    context 'when there is a multiplexer keyword' do
      let(:input) { { type: :string, any_of: any_of } }
      let(:any_of) { [{ type: 'null' }] }

      it { is_expected.to include(type: 'entity') }
      it { expect(boxed[:any_of]).to include(type: :string) }
      it { expect(boxed[:any_of]).to include(type: 'null') }
      it { expect(boxed[:any_of].last).to eq(type: :string) }
      it { expect(boxed[:any_of].last[:any_of]).not_to be_present }
    end
  end
end
