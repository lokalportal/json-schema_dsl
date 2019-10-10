# frozen_string_literal: true

describe JSON::SchemaDsl::Builder do
  include ::JSON::SchemaDsl
  after(:each) { described_class.type_defaults.clear }

  context 'when type defaults are given' do
    before(:each) { described_class.type_defaults.merge!(object: { additional_properties: false }) }

    it 'applies the defaults' do
      expect(object.additional_properties).to be false
    end

    context 'when the builder is nested' do
      let(:nested) do
        object do
          object :james
        end
      end

      it 'applies the defaults to the nested object' do
        expect(nested.children.first.additional_properties).to be false
      end
    end
  end
end
