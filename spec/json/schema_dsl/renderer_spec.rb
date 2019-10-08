# frozen_string_literal: true

describe JSON::SchemaDsl::Renderer do
  include JSON::SchemaDsl

  describe '.render' do
    subject { described_class.render(input) }

    shared_examples 'as a nullable entity' do
      %i[null nullable].each do |key|
        let(:input) { super().to_h.merge(key => true) }
        let(:any_of) { subject[:anyOf] }

        it { expect(any_of).to include(type: 'null') }
        it { expect(any_of.last).to include(type: input[:type]) }
      end
    end

    context 'given a complex object' do

      let(:input) do
        object :jeff do
          string :james_name, nullable: true, required: true
          additional_properties false
        end.to_h
      end

      let(:expected) do
        {
          type: 'object',
          additionalProperties: false,
          required: ['james_name'],
          properties: {
            james_name: {
              type: 'entity',
              anyOf: [
                { type: 'null' },
                { type: 'string' }
              ]
            }
          }
        }
      end

      it_behaves_like 'as a nullable entity'

      it 'is rendered correctly' do
        expect(subject.as_json).to eq(expected.as_json)
      end
    end

    context 'given a complex array' do
      let(:input) do
        array :cars do
          items type: :object do
            string :manufacturer
            array :extras, required: true do
              items do
                any_of [
                  object { # rubocop:disable Style/BlockDelimiters
                    string(:type, enum: 'Tire')
                    string(:position, required: true)
                  },
                  object { string(:type, enum: 'Wheel') }
                ]
              end
            end
          end
        end
      end

      let(:expected) do
        {
          type: :array,
          items: {
            type: :object,
            required: ['extras'],
            properties: {
              manufacturer: {
                type: :string
              },
              extras: {
                type: :array,
                items: {
                  type: 'entity',
                  anyOf: [
                    {
                      type: :object,
                      properties: {
                        type: {
                          type: :string,
                          enum: ['Tire']
                        },
                        position: {
                          type: :string
                        }
                      },
                      required: ['position']
                    },
                    {
                      type: :object,
                      properties: {
                        type: {
                          type: :string,
                          enum: ['Wheel']
                        }
                      }
                    }
                  ]
                }
              }
            }
          }

        }
      end

      it_behaves_like 'as a nullable entity'

      it 'is rendered correctly' do
        expect(subject.as_json).to eq(expected.as_json)
      end
    end
  end
end
