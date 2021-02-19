defmodule DryValidation.ValidatorTest do
  use ExSpec

  require DryValidation
  alias DryValidation.{Validator, Types}

  describe "#validate" do
    context "success" do
      test "simple schema" do
        schema =
          DryValidation.schema do
            required(:name, Types.String)
            optional(:age, Types.Integer)
            optional(:anything)
          end

        input = %{
          "name" => "Bob",
          "age" => 15,
          "anything" => true
        }

        {:ok, result} = Validator.validate(schema, input)
        assert result == input
      end

      test "optional" do
        schema =
          DryValidation.schema do
            required(:name, Types.String)
            optional(:age, Types.Integer)
          end

        input = %{
          "name" => "Bob"
        }

        {:ok, result} = Validator.validate(schema, input)
        assert result == input
      end

      test "casting" do
        schema =
          DryValidation.schema do
            required(:name, Types.String)
            optional(:age, Types.Integer)
          end

        input = %{
          "name" => 15,
          "age" => "25"
        }

        {:ok, result} = Validator.validate(schema, input)
        assert result == %{"name" => "15", "age" => 25}
      end

      test "nested map structure" do
        schema =
          DryValidation.schema do
            map :user do
              required(:name, Types.String)
              optional(:age, Types.Integer)
              optional(:gender, Types.String)

              map :pet do
                required(:name, Types.String)
              end

              map :mother do
                required(:name, Types.String)
              end
            end
          end

        input = %{
          "user" => %{
            "name" => "Jon",
            "age" => 15,
            "pet" => %{
              "name" => "Lab"
            },
            "mother" => %{
              "name" => "Jane"
            }
          }
        }

        {:ok, result} = Validator.validate(schema, input)
        assert result == input
      end

      test "optional nested map" do
        schema =
          DryValidation.schema do
            map :user, optional: true do
              required(:name, Types.String)
            end
          end

        input = %{}

        {:ok, result} = Validator.validate(schema, input)
        assert result == input
      end

      test "function calls" do
        schema =
          DryValidation.schema do
            required(:name, Types.Func.equal("Jon"))
            required(:age, Types.Integer.greater_than(5))
          end

        input = %{
          "name" => "Jon",
          "age" => 6
        }

        {:ok, result} = Validator.validate(schema, input)
        assert result == input
      end

      test "cast function calls" do
        schema =
          DryValidation.schema do
            required(:age, Types.Integer.greater_than(5))
          end

        input = %{"age" => "6"}

        {:ok, result} = Validator.validate(schema, input)
        assert result == %{"age" => 6}
      end

      test "list casting" do
        schema =
          DryValidation.schema do
            required(:numbers, Types.List.type(Types.Integer))
          end

        input = %{"numbers" => ["1", "2", 3]}
        {:ok, result} = Validator.validate(schema, input)
        assert result == %{"numbers" => [1, 2, 3]}
      end

      test "list function" do
        schema =
          DryValidation.schema do
            required(:numbers, Types.List.type(Types.Integer.greater_than(1)))
          end

        input = %{"numbers" => ["10", "2", 3]}
        {:ok, result} = Validator.validate(schema, input)
        assert result == %{"numbers" => [10, 2, 3]}
      end

      test "optional map_list" do
        schema =
          DryValidation.schema do
            map_list :people, optional: true do
              required(:name)
              optional(:age, Types.Integer)
            end
          end

        input = %{}

        {:ok, result} = Validator.validate(schema, input)
        assert result == %{}
      end

      test "map_list" do
        schema =
          DryValidation.schema do
            map_list :people do
              required(:name)
              optional(:age, Types.Integer)
            end
          end

        input = %{
          "people" => [
            %{"name" => "Jon", "age" => "5"},
            %{"name" => "Mark", "age" => 7}
          ]
        }

        {:ok, result} = Validator.validate(schema, input)

        assert result == %{
                 "people" => [
                   %{"name" => "Jon", "age" => 5},
                   %{"name" => "Mark", "age" => 7}
                 ]
               }
      end

      test "nested map_lists" do
        schema =
          DryValidation.schema do
            map_list :people do
              required(:name)
              optional(:age, Types.Integer)

              map_list :cars do
                required(:name)
                required(:cc, Types.Integer)
              end
            end
          end

        input = %{
          "people" => [
            %{"name" => "Jon", "age" => "5", "cars" => []},
            %{"name" => "Mark", "age" => 7, "cars" => [%{"name" => "Audi", "cc" => "1998"}]}
          ]
        }

        {:ok, result} = Validator.validate(schema, input)

        assert result == %{
                 "people" => [
                   %{"name" => "Jon", "age" => 5, "cars" => []},
                   %{"name" => "Mark", "age" => 7, "cars" => [%{"name" => "Audi", "cc" => 1998}]}
                 ]
               }
      end
    end

    context "failure" do
      test "required" do
        schema =
          DryValidation.schema do
            required(:name, Types.String)
          end

        input = %{
          "age" => 15
        }

        {:error, result} = Validator.validate(schema, input)
        assert result == %{"name" => "Is missing"}
      end

      test "optional wrong type" do
        schema =
          DryValidation.schema do
            optional(:age, Types.Integer)
          end

        input = %{
          "age" => "nonsense"
        }

        {:error, result} = Validator.validate(schema, input)

        assert result == %{
                 "age" =>
                   "\"nonsense\" is not a valid type; Expected type is DryValidation.Types.Integer"
               }
      end

      test "wrong type" do
        schema =
          DryValidation.schema do
            required(:age, Types.Integer)
          end

        input = %{
          "age" => "nonsense"
        }

        {:error, result} = Validator.validate(schema, input)

        assert result == %{
                 "age" =>
                   "\"nonsense\" is not a valid type; Expected type is DryValidation.Types.Integer"
               }
      end

      test "error in nested map structure" do
        schema =
          DryValidation.schema do
            map :user do
              required(:age, Types.Integer)

              map :father do
                required(:age, Types.Integer)
                optional(:city, Types.String)
              end

              map :mother do
                required(:age, Types.Integer)
                optional(:city, Types.String)
              end

              map :brother, optional: true do
                required(:age, Types.Integer)
                optional(:city, Types.String)
              end
            end
          end

        input = %{
          "user" => %{
            "name" => "Jon",
            "father" => %{}
          }
        }

        {:error, result} = Validator.validate(schema, input)

        assert result == %{
                 "user" => %{
                   "age" => "Is missing",
                   "father" => %{"age" => "Is missing"},
                   "mother" => "Is missing"
                 }
               }
      end

      test "function error messages" do
        schema =
          DryValidation.schema do
            required(:age, Types.Integer.greater_than(5))
            required(:type, Types.Func.equal("user"))
          end

        input = %{"age" => "4", "type" => "animal"}

        {:error, result} = Validator.validate(schema, input)

        assert result == %{
                 "age" => "4 is not greater than 5",
                 "type" => "\"animal\" is not equal to \"user\""
               }
      end

      test "when function receives wrong type" do
        schema =
          DryValidation.schema do
            required(:age, Types.Integer.greater_than(5))
          end

        input = %{"age" => "nonsense"}

        {:error, result} = Validator.validate(schema, input)

        assert result == %{
                 "age" =>
                   "\"nonsense\" is not a valid type; Expected type is DryValidation.Types.Integer"
               }
      end

      test "list wrong type" do
        schema =
          DryValidation.schema do
            required(:numbers, Types.List.type(Types.Integer))
          end

        input = %{"numbers" => ["1", "nonsense", 3]}
        {:error, result} = Validator.validate(schema, input)

        assert result == %{
                 "numbers" => "[\"nonsense\"] are not of type DryValidation.Types.Integer"
               }
      end

      test "when not a list" do
        schema =
          DryValidation.schema do
            required(:numbers, Types.List.type(Types.Integer))
          end

        input = %{"numbers" => "nonsense"}
        {:error, result} = Validator.validate(schema, input)
        assert result == %{"numbers" => "\"nonsense\" is not a List"}
      end

      test "list function error" do
        schema =
          DryValidation.schema do
            required(:numbers, Types.List.type(Types.Integer.greater_than(1)))
          end

        input = %{"numbers" => ["0", "1", "2", "3"]}
        {:error, result} = Validator.validate(schema, input)
        assert result == %{"numbers" => "[0, 1] is not greater than 1"}

        input = %{"numbers" => ["1", "nonsense", "3"]}
        {:error, result} = Validator.validate(schema, input)

        assert result == %{
                 "numbers" => "[\"nonsense\"] are not of type DryValidation.Types.Integer"
               }
      end

      test "map_list errors" do
        schema =
          DryValidation.schema do
            map_list :people do
              required(:name)
              optional(:age, Types.Integer)
            end
          end

        input = %{
          "people" => [
            %{"name" => "Jon", "age" => "5"},
            %{"name" => "Mark", "age" => "nonsense"}
          ]
        }

        {:error, result} = Validator.validate(schema, input)

        assert result == %{
                 "people" => [
                   [0, %{}],
                   [
                     1,
                     %{
                       "age" =>
                         "\"nonsense\" is not a valid type; Expected type is DryValidation.Types.Integer"
                     }
                   ]
                 ]
               }
      end

      test "nested map_lists errors" do
        schema =
          DryValidation.schema do
            map_list :people do
              required(:name)
              optional(:age, Types.Integer)

              map_list :cars do
                required(:name)
                required(:cc, Types.Integer)
              end
            end
          end

        input = %{
          "people" => [
            %{"name" => "Jon", "age" => "5", "cars" => []},
            %{"name" => "Mark", "age" => 7, "cars" => [%{"name" => "Audi", "cc" => "nonsense"}]}
          ]
        }

        {:error, result} = Validator.validate(schema, input)

        assert result == %{
                 "people" => [
                   [0, %{}],
                   [1, %{"cars" => [[0, %{"cc" => "\"nonsense\" is not a valid type; Expected type is DryValidation.Types.Integer"}]]}]
                 ]
               }
      end
    end
  end
end
