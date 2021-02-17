defmodule DryValidation.Types.Bool do
  def cast(value) when is_boolean(value), do: value
  def cast("true"), do: true
  def cast("false"), do: false
  def cast(value), do: value

  def valid?(value) when is_boolean(value), do: true
  def valid?(_value), do: false
end
