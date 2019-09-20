describe JSON::SchemaDsl do
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
