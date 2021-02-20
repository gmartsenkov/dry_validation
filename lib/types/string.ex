defmodule DryValidation.Types.String do
  @moduledoc """
  Represents a string type.
  ```
  DryValidation.schema do
    required :name, Types.String
  end
  ```
  """
  @doc false
  def cast(value), do: value

  @doc false
  def valid?(value) when is_binary(value), do: true
  def valid?(_value), do: false
end
