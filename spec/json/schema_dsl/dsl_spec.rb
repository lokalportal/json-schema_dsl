# frozen_string_literal: true

describe JSON::SchemaDsl do
  include JSON::SchemaDsl

  describe 'context helper methods' do
    let(:tree) do
      array do
        items do
          any_of james
        end
      end
    end

    def james
      [object, string]
    end

    it 'is able to use the instance methods' do
      expect { tree }.not_to raise_error
    end
  end
end
