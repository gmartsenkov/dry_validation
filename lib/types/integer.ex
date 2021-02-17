defmodule DryValidation.Types.Integer do
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
end
