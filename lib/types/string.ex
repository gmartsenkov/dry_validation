defmodule DryValidation.Types.String do
  def cast(value) when is_binary(value), do: value
  def cast(value), do: to_string(value)

  def valid?(value) when is_binary(value), do: true
  def valid?(_value), do: false
end
