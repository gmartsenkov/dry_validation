defmodule DryValidation.ValidatorTest do
  use ExSpec

  require DryValidation
  alias DryValidation.{Validator,Types}

  describe "#validate" do
    context "success" do
      test "simple schema" do
        schema = DryValidation.schema do
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
    end

    context "failure" do

    end
  end
end
