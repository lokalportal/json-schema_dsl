# frozen_string_literal: true

describe 'Array of any ofs' do
  include JSON::SchemaDsl

  subject do
    object do
      array :an_array do
        items do
          any_of [
            object { string(:a_string) },
            object { number(:a_number) }
          ]
        end
      end
    end
  end
  let(:expected_json) do
    {
      type: 'object',
      properties: {
        an_array: {
          type: 'array',
          items: {
            type: 'entity',
            anyOf: [
              {
                type: 'object',
                properties: {
                  a_string: {
                    type: 'string'
                  }
                }
              },
              {
                type: 'object',
                properties: {
                  a_number: {
                    type: 'number'
                  }
                }
              }
            ]
          }
        }
      }
    }
  end

  it 'matches' do
    expect(subject.render.as_json).to eq(expected_json.as_json)
  end
end
