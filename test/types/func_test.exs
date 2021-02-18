defmodule DryValidation.Types.FuncTest do
  use ExSpec

  alias DryValidation.Types

  describe "equal" do
    it "returns the correct struct" do
      assert %Types.Func{} = Types.Func.equal("text")
    end

    it "compares the values" do
      assert Types.Func.equal("text") |> Types.Func.call("text") == true
      assert Types.Func.equal("text") |> Types.Func.call("text1") == false
    end
  end
end
