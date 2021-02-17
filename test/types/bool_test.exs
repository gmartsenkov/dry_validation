defmodule DryValidation.Types.BoolTest do
  use ExSpec

  alias DryValidation.Types

  describe "#cast" do
    context "when not a bool" do
      it "converts true string to bool" do
        assert Types.Bool.cast("true") == true
        assert Types.Bool.cast("false") == false
      end

      it "returns the value when text" do
        assert Types.Bool.cast("nonsense") == "nonsense"
      end
    end

    context "when an bool" do
      it "returns the same value" do
        assert Types.Bool.cast(false) == false
      end
    end
  end

  describe "#valid?" do
    context "when value is bool" do
      it "returns true" do
        assert Types.Bool.valid?(false) == true
      end
    end

    context "when value is not a bool" do
      it "returns false" do
        assert Types.Bool.valid?("text") == false
      end
    end
  end
end
