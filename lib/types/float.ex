defmodule DryValidation.Types.Float do
  def cast(value) when is_float(value), do: value

  def cast(value) when is_binary(value) do
    case Float.parse(value) do
      {number, ""} -> number
      _ -> value
    end
  end

  def cast(value), do: value

  def valid?(value) when is_float(value), do: true
  def valid?(_value), do: false
end
