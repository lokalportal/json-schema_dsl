# frozen_string_literal: true

describe JSON::SchemaDsl::Renderers::Filter do
  describe '.visit' do
    subject(:filtered) { described_class.new(nil).visit(input) }

    context 'when there are no things to filter' do
      let(:input) { { type: :string } }

      it { is_expected.to eq(input) }
    end

    context 'when there are children' do
      let(:input) { { type: :object, properties: properties, children: children } }
      let(:properties) { { 'james' => { type: :string } } }
      let(:children) { [{ type: :string, name: 'james' }] }

      it { expect(filtered[:children]).to be_nil }
      it { expect(filtered[:properties]).to eq(properties) }
      it { is_expected.to eq(input.except(:children)) }
    end

    context 'when there are nil values' do
      let(:input) { { type: 'object', ref: nil } }

      it { expect(filtered.key?(:ref)).to be false }
    end

    context 'when there are false values' do
      let(:input) { { type: 'object', additional_properties: false } }

      it { expect(filtered.key?(:additional_properties)).to be true }
    end
  end
end
