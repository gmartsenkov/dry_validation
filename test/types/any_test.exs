defmodule DryValidation.Types.AnyTest do
  use ExSpec

  alias DryValidation.Types

  describe "cast" do
    it "returns the same value it was passed" do
      assert Types.Any.cast("text") == "text"
      assert Types.Any.cast(5) == 5
      assert Types.Any.cast(5.5) == 5.5
    end
  end

  describe "valid" do
    it "always returns true" do
      assert Types.Any.valid?("text")
      assert Types.Any.valid?(5)
      assert Types.Any.valid?(5.5)
    end
  end
end
