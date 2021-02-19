defmodule DryValidation.Types.StringTest do
  use ExSpec

  alias DryValidation.Types

  describe "#cast" do
    context "when not a string" do
      it "returns the passed value untouched" do
        assert Types.String.cast(5) == 5
      end
    end

    context "when a string" do
      it "returns the same value" do
        assert Types.String.cast("text") == "text"
      end
    end
  end

  describe "#valid?" do
    context "when value is string" do
      it "returns true" do
        assert Types.String.valid?("bob") == true
      end
    end

    context "when value is not a string" do
      it "returns false" do
        assert Types.String.valid?(5) == false
      end
    end
  end
end
