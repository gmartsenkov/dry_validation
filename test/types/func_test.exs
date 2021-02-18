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

  describe "#call" do
    it "calls the fn in the struct" do
      type = %Types.Func{fn: fn x -> x end}

      assert Types.Func.call(type, "a value") == "a value"
    end

    context "when type is set" do
      it "casts the value using the type before it's passed to the function" do
        type = %Types.Func{fn: fn x -> x end, type: Types.Integer}

        assert Types.Func.call(type, "5") == 5
      end
    end
  end
end
