defmodule DryValidation.Types.Float do
  @moduledoc """
  Represents a float type.
  Will try to cast strings into float values.
  ```
  DryValidation.schema do
    required :price, Types.Float
  end
  ```
  """

  @doc false
  def cast(value) when is_binary(value) do
    case Float.parse(value) do
      {number, ""} -> number
      _ -> value
    end
  end

  def cast(value), do: value

  @doc false
  def valid?(value) when is_float(value), do: true
  def valid?(_value), do: false
end
