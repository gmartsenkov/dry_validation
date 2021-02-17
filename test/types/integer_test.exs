defmodule DryValidation.Types.IntegerTest do
  use ExSpec

  alias DryValidation.Types

  describe "#cast" do
    context "when a string" do
      it "converts the value to integer" do
        assert Types.Integer.cast("110") == 110
      end

      it "returns the value when a float" do
        assert Types.Integer.cast("5.5") == "5.5"
      end

      it "returns the value when text" do
        assert Types.Integer.cast("nonsense") == "nonsense"
      end
    end

    context "when an integer" do
      it "returns the same value" do
        assert Types.Integer.cast(5) == 5
      end
    end
  end

  describe "#valid?" do
    context "when value is integer" do
      it "returns true" do
        assert Types.Integer.valid?(5) == true
      end
    end

    context "when value is not a integer" do
      it "returns false" do
        assert Types.Integer.valid?("text") == false
      end
    end
  end
end
