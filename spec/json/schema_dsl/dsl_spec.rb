# frozen_string_literal: true

describe JSON::SchemaDsl do
  describe 'context helper methods' do
    let(:dummy) do
      Class.new do
        include JSON::SchemaDsl

        def tree
          object do
            string :jeff
            object :data do
              helper
            end
          end
        end

        def helper
          object(:helper)
        end
      end
    end

    let(:expected) do
      {
        type: :object,
        properties: {
          jeff: { type: :string },
          data: {
            type: :object,
            properties: {
              helper: {
                type: :object
              }
            }
          }
        }
      }
    end

    it 'is able to use the instance methods' do
      expect { dummy.new.tree }.not_to raise_error
    end

    it 'is able not creating unnecessary children but using the return value' do
      expect(dummy.new.tree.as_json).to eq(expected.as_json)
    end
  end
end
