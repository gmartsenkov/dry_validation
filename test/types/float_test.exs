defmodule DryValidation.Types.FloatTest do
  use ExSpec

  alias DryValidation.Types

  describe "#cast" do
    context "when a string" do
      it "returns the value to float" do
        assert Types.Float.cast("5.5") == 5.5
      end

      it "converts the value to float" do
        assert Types.Float.cast("110") == 110.0
      end

      it "returns the value when text" do
        assert Types.Float.cast("nonsense") == "nonsense"
      end
    end

    context "when an float" do
      it "returns the same value" do
        assert Types.Float.cast(5) == 5
      end
    end
  end

  describe "#valid?" do
    context "when value is float" do
      it "returns true" do
        assert Types.Float.valid?(5.0) == true
      end
    end

    context "when value is not a float" do
      it "returns false" do
        assert Types.Float.valid?("text") == false
      end
    end
  end
end
