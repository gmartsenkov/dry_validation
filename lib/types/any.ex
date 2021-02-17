defmodule DryValidation.Types.Any do
  def cast(value), do: value

  def valid?(_value), do: true
end
