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

            map :pet, optional: true do
              required(:name)
            end

            map :parent do
              required(:eyes)
            end

            map :mother, optional: true do
              required(:name)
            end
          end

          optional(:gender)

          map :child, optional: true do
            required(:name)
          end
        end

        map :mother do
          required(:name)
        end

        map_list :pets do
          required(:name)
        end

        map_list :cars, optional: true do
          required(:name)

          map :engine do
            required(:cc)
          end

          required(:colour)

          map :make do
            required(:name)
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
                       },
                       %{
                         inner: [%{name: "name", rule: :required, type: nil}],
                         name: "pet",
                         optional: true,
                         rule: :map
                       },
                       %{
                         inner: [%{name: "eyes", rule: :required, type: nil}],
                         name: "parent",
                         optional: false,
                         rule: :map
                       },
                       %{
                         inner: [%{name: "name", rule: :required, type: nil}],
                         name: "mother",
                         optional: true,
                         rule: :map
                       }
                     ],
                     name: "parent",
                     rule: :map,
                     optional: true
                   },
                   %{name: "gender", type: nil, rule: :optional},
                   %{
                     inner: [
                       %{name: "name", type: nil, rule: :required}
                     ],
                     name: "child",
                     optional: true,
                     rule: :map
                   }
                 ],
                 name: "father",
                 rule: :map,
                 optional: false
               },
               %{
                 inner: [%{name: "name", rule: :required, type: nil}],
                 name: "mother",
                 optional: false,
                 rule: :map
               },
               %{
                 inner: [%{name: "name", rule: :required, type: nil}],
                 name: "pets",
                 optional: false,
                 rule: :map_list
               },
               %{
                 inner: [
                   %{name: "name", rule: :required, type: nil},
                   %{inner: [%{name: "cc", rule: :required, type: nil}], name: "engine", optional: false, rule: :map},
                   %{name: "colour", rule: :required, type: nil},
                   %{inner: [%{name: "name", rule: :required, type: nil}], name: "make", optional: false, rule: :map}
                 ],
                 name: "cars",
                 optional: true,
                 rule: :map_list
               }
             ]
  end
end
