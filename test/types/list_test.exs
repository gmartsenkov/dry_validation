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
    end
  end
end
