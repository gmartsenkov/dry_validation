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

  describe "#greater_than" do
    it "returns a Func struct" do
      assert %Types.Func{} = Types.Integer.greater_than(1)
    end

    it "works as expected" do
      assert Types.Integer.greater_than(1) |> Types.Func.call(2) == true
      assert Types.Integer.greater_than(1) |> Types.Func.call(1) == false
      assert Types.Integer.greater_than(1) |> Types.Func.call(0) == false
    end
  end

  describe "#greater_than_or_equal" do
    it "returns a Func struct" do
      assert %Types.Func{} = Types.Integer.greater_than_or_equal(1)
    end

    it "works as expected" do
      assert Types.Integer.greater_than_or_equal(1) |> Types.Func.call(2) == true
      assert Types.Integer.greater_than_or_equal(1) |> Types.Func.call(1) == true
      assert Types.Integer.greater_than_or_equal(1) |> Types.Func.call(0) == false
    end
  end

  describe "#less_than" do
    it "returns a Func struct" do
      assert %Types.Func{} = Types.Integer.less_than(1)
    end

    it "works as expected" do
      assert Types.Integer.less_than(1) |> Types.Func.call(-10) == true
      assert Types.Integer.less_than(1) |> Types.Func.call(0) == true
      assert Types.Integer.less_than(1) |> Types.Func.call(2) == false
      assert Types.Integer.less_than(1) |> Types.Func.call(1) == false
    end
  end

  describe "#less_than_or_equal" do
    it "returns a Func struct" do
      assert %Types.Func{} = Types.Integer.less_than_or_equal(1)
    end

    it "works as expected" do
      assert Types.Integer.less_than_or_equal(1) |> Types.Func.call(-10) == true
      assert Types.Integer.less_than_or_equal(1) |> Types.Func.call(0) == true
      assert Types.Integer.less_than_or_equal(1) |> Types.Func.call(2) == false
      assert Types.Integer.less_than_or_equal(1) |> Types.Func.call(1) == true
    end
  end
end
