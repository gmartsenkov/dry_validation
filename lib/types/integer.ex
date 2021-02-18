defmodule DryValidation.Types.Integer do
  alias DryValidation.Types.Func

  def cast(value) when is_number(value), do: value

  def cast(value) when is_binary(value) do
    case Integer.parse(value) do
      {number, ""} -> number
      _ -> value
    end
  end

  def cast(value), do: value

  def valid?(value) when is_number(value), do: true
  def valid?(_value), do: false

  def greater_than(value) do
    %Func{
      fn: fn v -> v > value end
    }
  end

  def greater_than_or_equal(value) do
    %Func{
      fn: fn v -> v >= value end
    }
  end

  def less_than(value) do
    %Func{
      fn: fn v -> v < value end
    }
  end

  def less_than_or_equal(value) do
    %Func{
      fn: fn v -> v <= value end
    }
  end
end
