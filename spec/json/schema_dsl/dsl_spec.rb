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

    it 'is able to use the instance methods' do
      expect { dummy.new.tree }.not_to raise_error
    end
  end
end
