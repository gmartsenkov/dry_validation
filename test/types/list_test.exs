defmodule DryValidation.Types.ListTest do
  use ExSpec

  alias DryValidation.Types

  describe "#call" do
    context "with list instance with type nil" do
      it "returns the same list it was passed" do
        list = [1, "string", 5.5]
        {:ok, result} = Types.List.call(%Types.List{}, list)
        assert result == list
      end
    end

    context "with Types.List module" do
      it "returns the same list it was passed" do
        list = [1, "string", 5.5]
        {:ok, result} = Types.List.call(Types.List, list)
        assert result == list
      end
    end

    context "when value is not a list" do
      it "returns an error" do
        {:error, :not_a_list} = Types.List.call(Types.List, "nonsense")
      end
    end

    context "when Type.List has a type" do
      it "casts the values correctly" do
        list = [1, "10", 5]
        {:ok, result} = Types.List.call(Types.List.type(Types.Integer), list)
        assert result == [1, 10, 5]
      end

      it "returns :ok when empty list" do
        list = []
        {:ok, result} = Types.List.call(Types.List.type(Types.Integer), list)
        assert result == []
      end

      it "returns the invalid elements" do
        list = [1, "nonsense", 5]
        {:error, result} = Types.List.call(Types.List.type(Types.Integer), list)
        assert result == ["nonsense"]
      end

      test "when list type is a Type.Func" do
        list = [2, "3", 4]
        {:ok, result} = Types.List.call(Types.List.type(Types.Integer.greater_than(1)), list)
        assert result == [2, 3, 4]
      end

      test  "when an error occurs for a Type.Func" do
        list = [1, 3, 4]
        {:error, bad_values, error_message} = Types.List.call(Types.List.type(Types.Integer.greater_than(1)), list)
        assert bad_values == [1]
        assert error_message == "is not greater than 1"
      end

      test  "when a type error occurs for a Type.Func" do
        list = [1, "nonsense", 4]
        {:error, bad_values, error_message} = Types.List.call(Types.List.type(Types.Integer.greater_than(1)), list)
        assert bad_values == ["nonsense"]
        assert error_message == "are not of type DryValidation.Types.Integer"
      end
    end
  end
end
