defmodule DryValidationTest do
  use ExUnit.Case
  doctest DryValidation

  test "generates the correct validation schema" do
    form =
      DryValidation.schema do
        required(:name)
        required(:age)

        map :father do
          required(:name)

          map :parent, optional: true do
            required(:gender)
            required(:birth_date)
          end
        end
      end

    assert form ==
             [
               %{name: "name", type: nil, rule: :required},
               %{name: "age", type: nil, rule: :required},
               %{
                 inner: [
                   %{name: "name", type: nil, rule: :required},
                   %{
                     inner: [
                       %{name: "gender", type: nil, rule: :required},
                       %{
                         name: "birth_date",
                         type: nil,
                         rule: :required
                       }
                     ],
                     name: "parent",
                     rule: :map,
                     optional: true
                   }
                 ],
                 name: "father",
                 rule: :map,
                 optional: false
               }
             ]
  end
end
