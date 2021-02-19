defmodule DryValidation.Types.FuncTest do
  use ExSpec

  alias DryValidation.Types

  describe "equal" do
    it "returns the correct struct" do
      assert %Types.Func{type: nil} = Types.Func.equal("text")
    end

    it "compares the values" do
      assert Types.Func.equal("text") |> Types.Func.call("text") == true
      assert Types.Func.equal("text") |> Types.Func.call("text1") == false
    end
  end

  describe "member_of" do
    it "returns the correct struct" do
      assert %Types.Func{type: nil} = Types.Func.member_of(["option1", "option2"])
    end

    it "compares the values" do
      assert Types.Func.member_of(["dog", "cat"]) |> Types.Func.call("dog") == true
      assert Types.Func.member_of(["dog", "cat"]) |> Types.Func.call("cat") == true
      assert Types.Func.member_of(["dog", "cat"]) |> Types.Func.call("horse") == false
    end
  end

  describe "#call" do
    it "calls the fn in the struct" do
      type = %Types.Func{fn: fn x -> x end}

      assert Types.Func.call(type, "a value") == "a value"
    end
  end

  describe "#cast" do
    context "when there is no type" do
      it "returns the same value" do
        assert Types.Func.cast(%Types.Func{}, "1") == "1"
        assert Types.Func.cast(%Types.Func{}, 5) == 5
      end
    end

    context "when there is a type set" do
      it "casts the value using the type" do
        assert Types.Func.cast(%Types.Func{type: Types.Integer}, "1") == 1
        assert Types.Func.cast(%Types.Func{type: Types.String}, 1) == "1"
      end
    end
  end
end
