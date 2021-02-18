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
          end

        input = %{
          "name" => "Bob",
          "age" => 15
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
            required(:age, Types.Integer)
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
              optional(:age, Types.String)
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
                 "age" => "Is not a valid type; Expected type is DryValidation.Types.Integer"
               }
      end

      test "error in nested map structure" do
        schema =
          DryValidation.schema do
            map :user do
              required(:age, Types.Integer)
            end
          end

        input = %{
          "user" => %{
            "name" => "Jon"
          }
        }

        {:error, result} = Validator.validate(schema, input)
        assert result == %{"user" => %{"age" => "Is missing"}}
      end
    end
  end
end
