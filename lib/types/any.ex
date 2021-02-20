defmodule DryValidation.Types.Any do
  @moduledoc """
  Represents any type, will not cast the value and will always assume that the value is valid.
  DryValidation.schema do
    required :anything, Types.Any
  end
  """
  @doc false
  def cast(value), do: value

  @doc false
  def valid?(_value), do: true
end
