defmodule DryValidation.Types.DateTest do
  use ExSpec

  alias DryValidation.Types

  describe "#cast" do
    context "when binary" do
      context "when a valid date" do
        it "returns the date" do
          assert Types.Date.cast("2023-10-05") == ~D[2023-10-05]
        end
      end

      context "with invalid date" do
        it "returns the same value" do
          assert Types.Date.cast("2023-10-005") == "2023-10-005"
        end
      end
    end

    context "when a date" do
      it "returns the same value" do
        assert Types.Date.cast(~D[2023-10-05]) == ~D[2023-10-05]
      end
    end
  end

  describe "#valid?" do
    context "when value is a date" do
      it "returns true" do
        assert Types.Date.valid?(~D[2023-10-05]) == true
      end
    end

    context "when value is not a date" do
      it "returns false" do
        assert Types.Date.valid?("text") == false
      end
    end
  end
end
