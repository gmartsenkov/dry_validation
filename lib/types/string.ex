defmodule DryValidation.Types.String do
  def cast(value), do: value

  def valid?(value) when is_binary(value), do: true
  def valid?(_value), do: false
end
